function [] = sift_plot(object, sift_object)
%SIFT_PLOT This function takes a reference object image as the input and
%plots the position of the detected features on the reference image with
%scale and orientation.
%   Orientation is represented with an arrow and scale with the arrow size.

% Plot the position, orientation, and scale of the features on the image.
figure;
% Parameter ordering: object, row, col,  scale, orientation
features_plot(object, sift_object{1}, sift_object{2}, sift_object{3}, sift_object{4});
title('Detected Features with Orientation and Scale')
