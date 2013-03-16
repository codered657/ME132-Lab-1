/*
 * This program grabs the left and right image (fast) from the bumblebee
 * camera and displays it using opencv. There is no stereo processing
 * done here which is why it is particularly fast. SIFT features are also
 * extracted and plotted for the right camera only.
 */

// include some standard header files
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// now include the opencv header files
#include <opencv/cv.h>
#include "opencv/cxcore.h"
#include <opencv/highgui.h>

// finally, include the bumblebee header file
#include "bb2.h"

// include the SIFT header files
#include <sift/sift.h>
#include <sift/imgfeatures.h>
#include <sift/utils.h>
#include <sift/kdtree.h>
#include <sift/xform.h>

#include <iostream>
#include <fstream>
#include <string>
#include <vector>

/* the maximum number of keypoint NN candidates to check during BBF search */
#define KDTREE_BBF_MAX_NN_CHKS     210
#define NN_SQ_DIST_RATIO_THR       0.30

using namespace std;
using namespace cv;

// this is the beginning of the "main" program
int main(int argc, char** argv)
{
    // what's the ID of the camera?
    int ID = 5020066;

    if (argc > 2)
    {
        ID = atoi(argv[1]);
    }
    else
    {
        fprintf(stderr, "missing argument. Need model ID and/or reference image.  Abort. \n");
        return -1;
    }

    // DEBUG: this will have to do until command line argument works
    // let's load the reference image into an opencv image container
    IplImage *reference_img = cvLoadImage(argv[2], CV_LOAD_IMAGE_GRAYSCALE);

    // Extract features from the reference image
    struct feature* database_features = NULL;
    cout << "Extracting features from the reference image..." << endl;
    int num_database_features = sift_features(reference_img, &database_features);

    // now build a kd-tree to hold the database features
    struct kd_node* kd_tree = NULL;
    kd_tree = kdtree_build(database_features, num_database_features);

    // let's create the bumblebee object with some default parameters
    // - the 2 is for stereo downscaling (1 means full image stereo, 2
    //   means half image)
    // - the true is a boolean indicating we're using a color camera
    int scale = 2;
    bool color = true;
    BumbleBee bb(ID, scale, color);

    // first let's initialize the bumblebee but stop the program if the
    // initialization fails
    if (bb.init() < 0)
    {
        return -1;
    }

    // what's the width and height of the camera? -- remember to scale it
    int width = bb.getImageWidth() / scale;
    int height = bb.getImageHeight() / scale;

    // now let's create an opencv image container to hold the left &
    // right image
    IplImage *left = cvCreateImage(cvSize(width, height), IPL_DEPTH_8U, 3);
    IplImage *right = cvCreateImage(cvSize(width, height), IPL_DEPTH_8U, 3);

    // let's create a buffer to hold the disparity image
    unsigned short disparity_buffer[width*height];

    // let's create two windows to display the left and right images
    cvNamedWindow("Left", 1);
    cvNamedWindow("Right", 1);

    struct feature* current_features;
    int num_current_features;

    // Allocate for final right image
    IplImage *right_img_final = cvCreateImage(cvSize(width, height), IPL_DEPTH_8U, 3);

    // Create a window to display the image
    cvNamedWindow("SIFT", 1);

    // Copy

    // now let's enter a while loop to continually capture from the
    // camera and display the image
    while(true)
    {
        // first thing we do is call the bumblebee to capture the images
        // and exit if the capture fails
        if (bb.capture() < 0)
        {
            printf("capture failed!\n");
            break;
        }

        // if here, then the capture succeeded so let's grab the left and
        // right rectified images and place them into the opencv containers
        // we setup earlier
        bb.getRectifiedColorBuffer((unsigned char*)left->imageData, BB_LEFT);
        bb.getRectifiedColorBuffer((unsigned char*)right->imageData, BB_RIGHT);

        // Save copy of right image before its modified with SIFT data
        //right_img_final = cvGetMat(right, temp_mat);
        right_img_final = cvCloneImage(right);

        // lets grab the disparity buffer too along with the row size
        int rowinc;
        bb.getDisparityImage(disparity_buffer, &rowinc);

        // extract SIFT features for the small right image only, plot them,
        // then calculate the 3d point to the first feature then delete them
        // to avoid memory leak
        current_features = NULL;
        num_current_features = sift_features(right, &current_features);
        printf("detected %d features ... \n", num_current_features);

        // Create a display image with reference image in top left and test
        // image (right stereo image) in bottom right
        int display_width = reference_img->width + right->width;
        int display_height = reference_img->height + right->height;
        IplImage *display_img = cvCreateImage(cvSize(display_width, display_height), IPL_DEPTH_8U, 3);
        cvZero(display_img); // Set background to black

        // Copy the reference image to the top left corner of the display image
        CvRect rect;
        rect.x = 0;
        rect.y = 0;
        rect.width = reference_img->width;
        rect.height = reference_img->height;
        cvSetImageROI(display_img, rect);
        cvCvtColor(reference_img, display_img, CV_GRAY2RGB);
        cvResetImageROI(display_img);

        // Copy the right stereo image to the bottom right corner of the display
        rect.x = reference_img->width;
        rect.y = reference_img->height;
        rect.width = right->width;
        rect.height = right->height;
        cvSetImageROI(display_img, rect);
        //cvCvtColor(right, display_img, CV_GRAY2RGB);
        cvCopy(right, display_img);
        cvResetImageROI(display_img);

        // Draw the database features (features from reference image)
        for (int i = 0; i < num_database_features; i++) {

            // Draw marker circle at at every feature point
            cvCircle(display_img,
                    cvPoint((int)database_features[i].img_pt.x, (int)database_features[i].img_pt.y),
                    1,
                    CV_RGB(255, 0, 0),
                    2,
                    8,
                    0
                    );
        }

        // Draw features from right stereo image on display image
        for(int i = 0; i < num_current_features; i++)
        {
            cvCircle(right,
                     cvPoint((int)current_features[i].img_pt.x + reference_img->width,
                             (int)current_features[i].img_pt.y + reference_img->height),  // feature point
                     1,
                     CV_RGB(255,0,0),
                     2,
                     8,
                     0
                     );

            // calculate distance to first feature and display it's XYZ in right
            // camera ref frame
            // TODO: remove?
            //if(i==0)
            //{
            //    int row, col;
            //    unsigned short disp;
            //    float x, y, z;
            //    row = (int)current_features[i].img_pt.y;
            //    col = (int)current_features[i].img_pt.x;
            //    disp = disparity_buffer[row*width + col];
            //    bb.disparityToXYZ(row, col, disp, &x, &y, &z);
            //    printf("feature 0 is at %f, %f, %f\n", x, y, z);
            //}
        }

        // Find the feature matches
        struct feature curr_feat;
        struct feature database_feat;
        struct feature** nbrs;
        double d0, d1;
        int k;
        for (int i = 0; i < num_current_features; i++) {

            curr_feat = current_features[i];
            k = kdtree_bbf_knn( kd_tree,
                                &curr_feat,
                                2,
                                &nbrs,
                                KDTREE_BBF_MAX_NN_CHKS
                                );

            if (k == 2) {

                d0 = descr_dist_sq(&curr_feat, nbrs[0]);
                d1 = descr_dist_sq(&curr_feat, nbrs[1]);
                if (d0 < d1 * NN_SQ_DIST_RATIO_THR) {

                    // Database feature matches the current feature
                    // curr_feat <==> database_feat
                    database_feat = *nbrs[0];

                    // Draw line between matching features
                    cvLine(display_img,
                        // database point from ref img
                        cvPoint((int)database_feat.img_pt.x, (int)database_feat.img_pt.y),
                        // current point from test img
                        cvPoint((int)curr_feat.img_pt.x + reference_img->width,
                                (int)curr_feat.img_pt.y + reference_img->height),
                        CV_RGB(0,255,0),
                        1,   // thickness
                        8,   // line type
                        0    // shift
                        );
                }
            }

        }

        // Show the display image
        cvShowImage("SIFT", display_img);

        // now let's display these captured images in the display windows we setup
        // earlier
        cvShowImage("Left", left);
        cvShowImage("Right", right);

        // TODO: Release the image?
        cvReleaseImage(&display_img);

        // now let's handle if a key was pressed, waiting up to 2 ms for it
        // if no key is pressed, then pressed_key < 0; otherwise, we exit on a
        // pressed key
        int pressed_key = cvWaitKey(3);
        if (pressed_key > 0)
        {
            // Exit, keeping current_features array until it is output to file
            break;
        }
        else
        {
            // If not done, free current list for next timestep
            free(current_features);
        }
    }

    // Loop through all values in disparity buffer, converting to 3D stero points
    ofstream stereo3D("right_stereo_3D.txt");
    cout << num_current_features;
    for (int row = 0; row < height; row++)
    {
    	for (int col = 0; col < width; col++)
       {
            unsigned short disp;
            float x, y, z;
            disp = disparity_buffer[row * height + col];
            bb.disparityToXYZ(row, col, disp, &x, &y, &z);

            // Extract RGB values from pixel
            uchar blue = ((uchar*)(right_img_final->imageData + right_img_final->widthStep*row))[col*3];
            uchar green = ((uchar*)(right_img_final->imageData + right_img_final->widthStep*row))[(col*3)+1];
            uchar red = ((uchar*)(right_img_final->imageData + right_img_final->widthStep*row))[(col*3)+2];

            // Output to text file in format <x>, <y>, <z>, <R>, <G>, <B>
            stereo3D << x << ", " << y << ", " << z << ", " << (unsigned int) red
                     << ", " << (unsigned int) green << ", " << (unsigned int) blue << endl;
        }
    }
    stereo3D.close();


    // Done with current_features array, ok to free it
    free(current_features);

    // cleanup, close, and finish the bumblebee camera
    bb.fini();

    // let's release those image containers we setup earlier
    cvReleaseImage(&right);
    cvReleaseImage(&left);
    cvReleaseImage(&right_img_final);

    // finally, let's destroy those windows we setup to display the images
    cvDestroyWindow("Left");
    cvDestroyWindow("Right");
    cvDestroyWindow("SIFT");

    return 0;
}