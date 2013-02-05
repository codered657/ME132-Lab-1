
Contents of sift/:

    sift_detector.m  The function which you might call. It converts rgb to 
                     grayscale and it converts the output of sift.m in a format
                     slightly easier to use. You can use sift.m directly if you
                     wish.
    
    sift.m          The matlab wrapper for the two executables that do the 
                    real work.
    sift            Executable for Linux performing the feature extraction. 
    siftWin32.exe   Executable for Windows
                    (sorry, no OS X version yet --- let us know if you need it,
                     we'll find it for you)


Contents of sensor_data/:

    object_01.jpg        The object database.  
    ...
    object_12.jpg


Contents of sensor_data/:

    example_01.mat       Three examples for the sensor data with ground truth.
    example_02.mat
    example_03.mat

						If you don't want to use MATLAB, the raw data is 
                        included as well in an XYZ file and a solution file. 
 
                     The format of XYZ file is:
                        
                        <height> <width>
                        
                     followed by  <height> * 3 lines each describing an image 
					 row for X,Y,Z in sequence.
                     See convert_to_matlab.py for an example of how to read it.

    
    example_display.m    Script for visualizing the examples.
    
    
                       
