

sensor_data = load('../sensor_data/example_01.mat');

[row, col, scale, orientation, descriptors] = sift_detector(sensor_data.rgb);

figure;
features_plot(sensor_data.rgb, row, col,  scale, orientation);
title('descriptors')

% there's not a good way to show the descriptors
figure;
imshow(descriptors)
title('descriptors')