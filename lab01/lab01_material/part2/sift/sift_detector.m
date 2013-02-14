function [row, col, scale, orientation, descriptors] = sift_detector(rgb)
% This is a simple wrapper around sift() that converts the rgb image
% to grayscale and it makes it a bit easier to read the results.
%
%  row,col:     feature position in image coordinates
%  scale:       vector of size N giving the feature scale
%  orientation: vector of size N giving the feature orientation in radians
%  descriptors: vector of size Nx128 giving the SIFT descriptor
%                 d = descriptors(i,:) access the descriptor for the i-th feature
%
rgb = double(rgb);
% This is the simplest way to convert RGB to grayscale
% http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
k = [0.3 0.59 0.11];
grayscale = rgb(:,:,1)*k(1) + rgb(:,:,2)*k(2) + rgb(:,:,3)*k(3);
[descriptors, locs] = sift(grayscale);
row = locs(:,1);
col = locs(:,2);
scale = locs(:,3);
orientation = locs(:,4);
