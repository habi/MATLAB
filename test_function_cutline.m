clear all;
close all;
clc;

image1=phantom(512);
%image1 = imnoise(image1,'gaussian',0,1e-6);
% image2=image1(:,1:312);
% image1=image1(:,201:512);
image1 = double(imread('/sls/X02DA/Data10/e11126/2008b/R243b10c_s3/tif/R243b10c_s30013.tif'));
image2 = double(imread('/sls/X02DA/Data10/e11126/2008b/R243b10_s3/tif/R243b10_s30013.tif'));
flat1 = double(imread('/sls/X02DA/Data10/e11126/2008b/R243b10c_s3/tif/R243b10c_s30012.tif'));
flat2 = double(imread('/sls/X02DA/Data10/e11126/2008b/R243b10_s3/tif/R243b10_s30012.tif'));
image1 = image1 ./ flat1;
image2 = image2 ./ flat2;
image1 = imrotate(image1,90);
image2 = imrotate(image2,90);

%cutline = function_cutline(image2,image1)
cutline = -4
if cutline < 0
    mergeimage = [ image2 image1(:,abs(cutline)+1:size(image1,2)) ];
elseif cutline == 0
    mergeimage = [ image2 image1 ];
else
   mergeimage = [ image1 image2(:,abs(cutline)+1:size(image1,2)) ];
end

figure
    imshow(mergeimage(:,513:1536),[])
    axis on