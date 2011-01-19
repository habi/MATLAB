clc;
clear all;
close all;

Image = phantom;
%Sinogram = radon(Image);
NumberOfProjections = [ 256 32 256 ];
%IntImg=fct_InterpolateImageRows(Image,NumberOfProjections(1)/NumberOfProjections(2));
[ AbsoluteError, ErrorPerPixel] = fct_ErrorCalculation(Image,NumberOfProjections,Image)
