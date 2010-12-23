function [lengths] = image_measure;
% Estimate lengths on an image by point-click.
% [lengths] = image_measure;
%
% This function prompts the user to select an image file to open, then
% opens and plots the image.  The program waits for the user to resize the
% image if desired.  The user then:
% 1.) left-clicks on the endpoints of a known dimension in the image to
% establish a reference length and then
% 2.) types the length of the reference in a dialog box,
% 3.) clicks on as many pairs of points as desired in the image to measure
% their separation distance relative to the reference.
%
% Matt Allen, Fall 2007

[filename,pathname] = uigetfile('*.bmp;','Pick an Image File'); % *.tif;*.jpg;*.png;
im_data = imread([pathname,filename]);

figure; image(im_data)

input('Press any key when ready to proceed');

axis image % make sure image is not distorted before starting

[xr,yr] = ginput(2)
line(xr,yr,'Marker','+','Color','b');

l_ref_img = norm([xr(1),yr(1)]-[xr(2),yr(2)]);

% Prompt for length of this line:
    prompt = {'Enter the length of the reference line:'};
    dlg_title = 'Length of Ref. Line';
    num_lines = 1;
    def = {'1'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    lscale = str2num(answer{1})/l_ref_img;
    
    % Displace labels slightly
    text(xr(1),yr(1),num2str(l_ref_img*lscale),'Color','b');

% Zoom out if Right mouse button is depressed.  If the middle button is
% depressed, zoom in again.
loop_break = 0; meas_num = 1;
while loop_break == 0;
    [x1,y1,mbutton] = ginput(1);
    line(x1,y1,'Marker','+','Color','y');
    if mbutton == 3;
        loop_break = 1;
        % This signifies that the user is done
    elseif mbutton == 1;
        % Get second point and measure
        [x2,y2,mbutton] = ginput(1);
        if mbutton == 3; loop_break = 1; break; end
        line([x1,x2],[y1,y2],'Marker','+','Color','r');
        lengths(meas_num) = norm([x1,y1]-[x2,y2])*lscale;
        meas_num = meas_num +1;
        text(x1,y1,num2str(lengths(meas_num-1)),'Color','r');
    end
end


