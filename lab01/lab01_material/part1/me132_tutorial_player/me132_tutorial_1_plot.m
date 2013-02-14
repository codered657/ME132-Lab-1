function [] = me132_tutorial_1_plot(filename)
% This function takes in a data file of robot poses and laser scans and
% plots them.

% Read in data
data = csvread(filename);
x = data(:,1);
y = data(:,2);
yaw = data(:,3);
range = data(:,4);
bearing = data(:,5);

% Truncate range to 8
x = x(range < 8);
y = y(range < 8);
yaw = yaw(range < 8);
bearing = bearing(range < 8);
range = range(range < 8); % must be last to update to not interfere

% Convert into room coordinates
x_room = x + range .* cos(yaw + bearing);
y_room = y + range .* sin(yaw + bearing);

% Plot room data
figure;
scatter(x_room, y_room, 2.5);
title('Room Points from Laser Scan Data')
