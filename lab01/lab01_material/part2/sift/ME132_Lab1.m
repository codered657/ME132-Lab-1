% Tiffany Huang, Shir Aharon, Steven Okai
% ME/CS 132a
% Lab 1
% Part 2

clc           % Clear command window
clear all     % Clear all variables
close all     % Close all figures

%% Define Consants
% List of object files
obj_files = {'../object_imgs/object_01.jpg'; '../object_imgs/object_02.jpg'; ...
             '../object_imgs/object_03.jpg'; '../object_imgs/object_04.jpg'; ...
             '../object_imgs/object_05.jpg'; '../object_imgs/object_06.jpg'; ...
             '../object_imgs/object_07.jpg'; '../object_imgs/object_08.jpg'; ...
             '../object_imgs/object_09.jpg'; '../object_imgs/object_10.jpg'; ...
             '../object_imgs/object_11.jpg'; '../object_imgs/object_12.jpg';};
num_obj = length(obj_files);
sensor_files = {'../sensor_data/example_01.mat'; '../sensor_data/example_02.mat'; ...
                '../sensor_data/example_03.mat'};
num_sens = length(sensor_files);

%% Load object images and sensor data
tic;
obj_list = cell(num_obj, 1);
for i = 1:num_obj
    obj_list{i} = imread(obj_files{i});
end
sensor_list = cell(num_sens, 1);
for i = 1:num_sens
    sensor_list{i} = load(sensor_files{i});
end
t = toc;
disp(strcat('Time to load images was ', num2str(t)));

%% Extract sift data for everything once for efficiency
tic;
% Allocate space for data
sift_data_obj = cell(num_obj,1);
sift_data_sens = cell(num_sens,1);
for i = 1:num_obj
    sift_data_obj{1} = cell(5, 1);
end
for i = 1:num_sens
    sift_data_sens{1} = cell(5, 1);
end
% Parse out data from sift_detector
for i = 1:num_obj
    [sift_data_obj{i}{1}, sift_data_obj{i}{2}, sift_data_obj{i}{3}, ...
        sift_data_obj{i}{4}, sift_data_obj{i}{5}] = sift_detector(obj_list{i});
end
for i = 1:num_sens
    [sift_data_sens{i}{1}, sift_data_sens{i}{2}, sift_data_sens{i}{3}, ...
        sift_data_sens{i}{4}, sift_data_sens{i}{5}] = sift_detector(sensor_list{i}.rgb);
end
t = toc;
disp(strcat('Time run sift was ', num2str(t)));

%% Figure A
tic;
for i = 1:num_obj
    sift_plot(obj_list{i}, sift_data_obj{i})
end
t = toc;
disp(strcat('Time for figure A ', num2str(t)));

%% Figure B
tic;
for i = 1:num_sens
    sift_plot(sensor_list{i}.rgb, sift_data_sens{i})
end
t = toc;
disp(strcat('Time for figure B ', num2str(t)));

%% Figure C
tic;
for i = 3:num_sens
    object_detector(sift_data_sens{i}, sift_data_obj);
end
t = toc;
disp(strcat('Time for figure C ', num2str(t)));
