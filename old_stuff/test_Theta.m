clc;
clear;
close all;

Image=phantom(256);
Sinogram=radon(Image,1:180/16:180);
Reconstruction=iradon(Sinogram,1:180/16:180);
% I = iradon(R,theta,interp,filter,frequency_scaling,output_size)
figure;
    subplot(1,3,1)
        imshow(Image,[])
        title(size(Image))
        axis image
    subplot(1,3,2)
        imshow(Sinogram',[])
        title(size(Sinogram))      
        axis image
    subplot(1,3,3)
        imshow(Reconstruction,[])
        title(size(Reconstruction))
        axis image