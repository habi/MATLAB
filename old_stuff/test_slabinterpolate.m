clc;
clear;
close all;

InputImage  = phantom(256);
OutputImage = h_Slabinterpolate(InputImage',3);
Diff=InputImage-OutputImage;

figure(1);
colormap gray;
imagesc(InputImage);
title('Phantom');

figure(2);
colormap gray;
imagesc(OutputImage);
title('Interpolated Image');

figure(3);
colormap gray;
imagesc(Diff);
title('Difference Image');

SizeInput = size(InputImage)
SizeOutput = size(OutputImage)
