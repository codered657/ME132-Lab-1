function H = ransac(dataset, p_suc, p_in)
%RANSAC This function takes a number of points required (n), a set of
%image feature points, the probability of success, and the probability of a
%sample being an inlier as input. It determines the best fit for the data and
%which points are outliers. The function outputs the data set without the 
%outliers.

% Determine S (number of trials needed to select best H matrix) and set a
% threshold value for the reprojection error.

k = 4;
S = log(1-p_suc)/log(1-p_in^k);

% Define constants for function
threshold = 5;
num_points = size(dataset,2);

% Initialize search
count_max = 0;

P = dataset(:,1:2)';
Q = dataset(:,3:4)';

H = ones(3);
for s = 1:ceil(S)
    % Draw a sample of n points from the data randomly.

    indices = zeros(1,k);
    for v = 1:k
        indices(1,v) = randi([1, num_points]);
    end
    X1 = P(1,indices);
    Y1 = P(2,indices);
    X2 = Q(1,indices);
    Y2 = Q(2,indices);
    
    % Determine the H matrix from the random sample of points.
    
    points = [X2(1); Y2(1); X2(2); Y2(2); X2(3); Y2(3); X2(4); Y2(4)];

    M = zeros(2*k);
    m = 1;
    for i = 1:2:2*k
        M([i i+1],:) = [X1(m), Y1(m), 1, 0, 0, 0, -X2(m)*X1(m), -X2(m)*Y1(m);...
                        0, 0, 0, X1(m), Y1(m), 1, -Y2(m)*X1(m), -Y2(m)*Y1(m)];
        m = m + 1;
    end
    H_vector = M\points;
    
    % Calculate the reprojection error between a pair of corresponding feature
    % points (P,Q).
    error = zeros(num_points,1);
    for e = 1:length(dataset)
        HP = [(H_vector(1,1)*P(1,e)+H_vector(2,1)*P(2,e)+H_vector(3,1))/(H_vector(7,1)*P(1,e)+H_vector(8,1)*P(2,e)+1); (H_vector(4,1)*P(1,e)+H_vector(5,1)*P(2,e)+H_vector(6,1))/(H_vector(7,1)*P(1,e)+H_vector(8,1)*P(2,e)+1)];
        error(e) = (sum((Q(:,e) - HP).^2,1)).^0.5;
    end
    
    % Get number of elements with error below the threshold
    count = length(error(error < threshold));
    
    if count > count_max
        H = reshape([H_vector, ;0], 3, 3);
        count_max = count;
        %error_list = error;
    end
end

% Once the H matrix with the least error is found, use it to find the
% inliers and outliers by comparing the error between each match of feature
% points with the threshold.

% inliers = zeros(0,4);
% outliers = zeros(0,4);
% 
% for j = 1:num_points
%     if error_list(j) < threshold
%         inliers = cat(1,inliers,dataset(j,:));
%     else
%         outliers = cat(1,outliers,dataset(j,:));
%     end
% end


