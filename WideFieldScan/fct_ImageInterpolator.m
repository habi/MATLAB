function InterpolatedImages=fct_ImageInterpolator(ImageToInterpolate1,ImageToInterpolate2,InterpolateHowManyInbetween)
% function takes two Input Images and a factor of how many Images should be
% interpolated between the two Input Images. This factor incluences the
% grid distance of the meshgrid, which is used to calculate the
% interpolation.
% The output of the function is a stack of images with the first and the
% last slice set as the two Input Images and the images inbetween with the
% interpolated images, thus having a size of
% x,y,InterpolateHowManyInbetween+2, where x and y are the size of the
% input-images.

InterpolatedImages = [];

if nargin ~= 3
    disp('The Image Interpolation function needs Two Images and the information on how many images')
	disp('should be interpolated inbetween. You did not provide three inputs!')
    return
end

if size(ImageToInterpolate1) ~= size(ImageToInterpolate2)
    disp('The two input images need to be the same size, you provided different sizes!')
    return
end

ImageStack(:,:,1) = double(ImageToInterpolate1);
ImageStack(:,:,2) = double(ImageToInterpolate2);

x=1:size(ImageToInterpolate1,1);
y=1:size(ImageToInterpolate1,2);
z=1:2;
[xi,yi,zi] = meshgrid(1:size(ImageToInterpolate1,1),...
    1:size(ImageToInterpolate1,2),...
    1:(1/(InterpolateHowManyInbetween+1)):2);
disp(['Interpolating ' num2str(InterpolateHowManyInbetween) ' image(s). This might take long...'])
InterpolatedImages = interp3(x,y,z,ImageStack,xi,yi,zi);

clear ImageStack
end