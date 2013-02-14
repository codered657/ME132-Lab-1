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
freq_list = cell(num_sens,1);
feature_list = cell(num_sens,1);
for i = 1:num_sens
    [freq_list{i} feature_list{i}] = object_detector(sift_data_sens{i}, sift_data_obj);
end
t = toc;
disp(strcat('Time for figure C ', num2str(t)));

%% Figure D, E, F
for i = 1:num_sens
    % Determine which objects are "detected."
    detected_threshold = 60;
    num_obj = 1:length(freq_list{i});
    num_obj = num_obj(freq_list{i} > detected_threshold);
    for j = num_obj
        % Figure D
        obj_feature = feature_list{i}(:, feature_list{i}(1,:) == j);
        figure;
        colors = hsv(length(obj_feature));
        subplot(1,2,2);
        imshow(sensor_list{i}.rgb);
        hold on
        for k = 1:size(obj_feature,2)
            plot(obj_feature(2,k),obj_feature(3,k),'o','MarkerEdgeColor',colors(k,:))
        end
        subplot(1,2,1);
        imshow(obj_list{j});
        hold on
        for k = 1:size(obj_feature,2)
            plot(obj_feature(4,k),obj_feature(5,k),'o','MarkerEdgeColor',colors(k,:))
        end
        hold off
        % Figure E
        feature_match_list = correspondence_plot(sift_data_sens{i}, sift_data_obj{j},...
                                                 sensor_list{i}.rgb, obj_list{j});
       % Figure F
       H = ransac(feature_match_list, 0.999, 0.5)
        objX = sift_data_obj{j}{2};
        objY = sift_data_obj{j}{1};
        sensX = zeros(length(objX),1);
        sensY = zeros(length(objX),1);
        for k = 1:length(objX)
            reproj = (H + eye(3))^-1 * [objX(k,1); objY(k,1); 1];
            sensX(k) = reproj(1,1);
            sensY(k) = reproj(2,1);
        end
        figure;
        colors = hsv(length(objX));
        subplot(1,2,2);
        imshow(sensor_list{i}.rgb);
        hold on
        for k = 1:length(objX)
            plot(sensX(k), sensY(k),'o','MarkerEdgeColor',colors(k,:))
        end
        subplot(1,2,1);
        imshow(obj_list{j});
        hold on
        for k = 1:length(objX)
            plot(objX(k), objY(k),'o','MarkerEdgeColor',colors(k,:))
        end
        hold off
    end
end
