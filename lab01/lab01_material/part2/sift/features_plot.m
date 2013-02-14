function features_plot(rgb, row, col, orientation, scale)
imshow(rgb)
hold on;
% note the inversion of coordinates
% plot(col, row, 'rx')

% you might want to plot orientation and scale as well here
% change the orientation and scale to cartesian coordinates
u = scale.*cos(orientation);
v = scale.*sin(orientation);
quiver(col, row, u, v)