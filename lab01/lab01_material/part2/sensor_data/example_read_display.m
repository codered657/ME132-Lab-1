function display_example(filename)
	% Displays the example data 
	%
	% Run as:  
	%   display_example('example_01')

	data = load(filename);
	X = data.XYZ(:,:,1);
	Y = data.XYZ(:,:,2);
	Z = data.XYZ(:,:,3);	
	range = sqrt(X.^2 + Y.^2 +Z.^2);
	

	figure; 
	imshow(X);
	title('X');
	
	
	figure; 
	imshow(Y);
	title('Y');

	figure; 
	imshow(Z);
	title('Z');
	
	figure; 
	imshow(range);
	title('range');

	figure; 
	imshow(data.rgb)
	hold on;
	for i=1:numel(data.objects)
		object_id = data.objects(i).id;
		object_pos= double(data.objects(i).position)

		% NOTE (col, row) for using plot + imshow
		plot(object_pos(2), object_pos(1), 'rx')
		h=text( object_pos(2), object_pos(1), object_id);
		set(h, 'color', 'white', 'Interpreter', 'none')
		title('RGB image')
	end
