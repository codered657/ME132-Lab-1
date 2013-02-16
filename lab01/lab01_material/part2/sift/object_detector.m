function [freq, feature_list] = object_detector(sift_data_image, sift_obj_list)
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

feature_list = [];
% Iterate over each object
for j = 1:length(descriptors_s)
    ssd_all = [];
    for i = 1:num_obj
        % For each feature, calculate the SSD between the SIFT descriptor vectors
        % of the sensor image and each of the reference images.
        ssd = zeros(1, length(descriptors_obj{i}));
        for k = 1:length(descriptors_obj{i})
           ssd(k) = sum((descriptors_s(j,:) - descriptors_obj{i}(k,:)).^2);
        end
        ssd_all = [ssd_all, ssd];
    end

    % Set the ratio threshold and minimums.
    sorted_ssd = sort(ssd_all);
    min_ssd = sorted_ssd(1);
    min2_ssd = sorted_ssd(2);
    ratio = min_ssd / min2_ssd;

    % Update histogram data and figure out which object image belongs to
    if (ratio < threshold)
        idx = find(ssd_all == min_ssd);
        i = 1;
        while (idx > length(descriptors_obj{i}))
            idx = idx - length(descriptors_obj{i});
            i = i + 1;
        end
        freq(i) = freq(i) + 1;
        feature_list = [feature_list [i; sift_data_image{2}(j); sift_data_image{1}(j); ...
                        sift_obj_list{i}{2}(idx); sift_obj_list{i}{1}(idx)]];
    end
end

% Display histogram
figure;
bar(freq)
