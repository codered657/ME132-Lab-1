function [feature_match_array] = correspondence_plot(sift_data_image, sift_obj,  data_image, obj)
% CORRESPONDENCE_PLOT This function shows the corresponding features in the
% sensor image and the reference image. It takes an array containing the
% number of matches each image in the database has with the sensor image.

% Define constants for function
ratio_threshold = 0.6;
feature_match_array = zeros(0,4);

% For each feature in the sensor image, look through each of the features
% in the detected object and find the corresponding feature.

% Extract descriptor data for convenience
descriptors_s = sift_data_image{5};
descriptors_obj = sift_obj{5};

% Iterate over each object
for j = 1:length(descriptors_s)
    % For each feature in the sensor image, calculate the SSD between
    % the SIFT descriptor vectors of the features in the sensor image
    % and the detected reference image(s).
    ssd = zeros(1, length(descriptors_obj));
    for k = 1:length(descriptors_obj)
        ssd(k) = sum((descriptors_s(j,:) - descriptors_obj(k,:)).^2);
    end

    % Set the minimums.
    sorted_ssd = sort(ssd);
    min_ssd = sorted_ssd(1);
    min2_ssd = sorted_ssd(2);
    ratio = min_ssd / min2_ssd;
    index = find(ssd == min_ssd);

    % Update feature_matching_array
    if ratio < ratio_threshold
        feature_match_array = cat(1, feature_match_array, ...
            [sift_data_image{1}(j), sift_data_image{2}(j), ...
             sift_obj{1}(index) sift_obj{2}(index)]);
    end
end

% Plot the corresponding features with the same color.
% Note: plotting assumes only 1 object image was matched to
figure;
colors = hsv(size(feature_match_array,1));
subplot(1,2,2);
imshow(data_image);
hold on
for i = 1:size(feature_match_array,1)
    plot(feature_match_array(i,2), feature_match_array(i,1),'o','MarkerEdgeColor',colors(i,:))
end
subplot(1,2,1);
imshow(obj);
hold on
for i = 1:size(feature_match_array,1)
    plot(feature_match_array(i,4), feature_match_array(i,3),'o','MarkerEdgeColor',colors(i,:))
end
hold off
