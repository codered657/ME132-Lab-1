function [freq, idx] = object_detector(sift_data_image, sift_obj_list)
%OBJECT_DETECTOR This function matches each feature in the image from the
%sensor data and matches it with features in the object database. It takes
%the sensor image and the images in the object database as input and
%outputs a histogram showing the number of matches for each reference
%object.
%
%   Similarities are defined using the sum of square differences and the 
%best match is found by using a ratio threshold for comparing the ratio of 
%the similarity of the first and second best match.

% Define constants in problem
num_obj = length(sift_obj_list);
threshold = 0.6;

% Initialize list to keep histogram data in
freq = zeros(num_obj, 1);

% Extract descriptor data for convenience
descriptors_s = sift_data_image{5};
descriptors_obj = cell(num_obj, 1);
for i = 1:num_obj
    descriptors_obj{i} = sift_obj_list{i}{5};
end

% Iterate over each object
for i = 1:num_obj
    for j = 1:length(descriptors_s)
        % For each feature, calculate the SSD between the SIFT descriptor vectors
        % of the sensor image and each of the reference images.
        ssd = zeros(1, length(descriptors_obj{i}));
        for k = 1:length(descriptors_obj{i})
           ssd(k) = sum((descriptors_s(j,:) - descriptors_obj{i}(k,:)).^2);
        end

        % Set the ratio threshold and minimums.
        sorted_ssd = sort(ssd);
        min_ssd = sorted_ssd(1);
        min2_ssd = sorted_ssd(2);
        ratio = min_ssd / min2_ssd;
        
        % Update histogram data
        if (ratio < threshold)
            freq(i) = freq(i) + 1;
        end
    end
end

% Display histogram
figure;
bar(freq)

% Return idx of object image with most matches
[~, idx] = max(freq);
