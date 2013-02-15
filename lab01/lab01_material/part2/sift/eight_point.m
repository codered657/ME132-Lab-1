function F = eight_point(K,R1,T1,R2,T2)
%EIGHT_POINT Runs the eight-point algorithm to output the fundamental (F)
%matrix for motion from two views. The function takes the calibration
%matrix K, the rotation matrix R and the translation matrix T as input.

% Generate a random 8-point cloud of 3-D points.
world = rand(3,8);

% Transform the 8 world points to camera points at the two camera poses
% using R1, R2 and T1, T2.
camera1 = zeros(3,8);
camera2 = zeros(3,8);
for i = 1:8
    camera1(:,i) = K*(R1*world(:,i)+T1);
    camera2(:,i) = K*(R2*world(:,i)+T2);
end

% Create the 'A matrix' which multiplied by the F column vector equals 0.
A = [camera1(1,:).*camera2(1,:); camera1(1,:).*camera2(2,:); camera1(1,:).*camera2(3,:); ...
     camera1(2,:).*camera2(1,:); camera1(2,:).*camera2(2,:); camera1(2,:).*camera2(3,:); ...
     camera1(3,:).*camera2(1,:); camera1(3,:).*camera2(2,:); camera1(3,:).*camera2(3,:)]';

% Find the singular value decomposition of the 'A matrix' to find F.
[~,~,V] = svd(A);

% The F column vector is the column of the V matrix that corresponds to the
% smallest singular value in S.
F = reshape(V(:,9),3,3);

% To get a better estimate of F, find the SVD of F and set the smallest
% singular value of S1 to 0.
[U1,S1,V1] = svd(F);
S1(3,3) = 0;
% Use this new S1 to find a better estimate of F.
F = U1*S1*V1';

% Use this F to estimate the essential matrix E.
E = K'*F*K

end

