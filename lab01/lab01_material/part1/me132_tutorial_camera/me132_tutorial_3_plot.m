function [] = me132_tutorial_3_plot(filename)
% This function takes in a data file of robot poses and laser scans and
% plots them.

% Read in data
data = csvread(filename);
x = data(:,1);
y = data(:,2);
z = data(:,3);
r = data(:,4) / 255;
g = data(:,5) / 255;
b = data(:,6) / 255;

% Plot room data
figure;
scatter3(x, y, z, 4, [r,g,b]);
title('Room Points from Laser Scan Data')
