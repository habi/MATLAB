clc;
close all;
clear;

%Phantom=phantom(512);
Phantom = double(imread('/afs/psi.ch/user/h/haberthuer/images/phantom512.png','png'));
theta=0:180;
Sinogram=radon(Phantom,theta);
Reconstruction=iradon(Sinogram,theta);

figure;
colormap gray;
imagesc(Phantom);
axis image;
print('-depsc','explanation-phantom');

figure;
colormap gray;
imagesc(Sinogram');
axis image;           
print('-depsc','explanation-sinogram');


figure;
colormap gray;
imagesc(Reconstruction);
axis image;
print('-depsc','explanation-reconstruction');

% imwrite(Phantom,'explanation-phantom.jpg');
% imwrite(Sinogram','explanation-sinogram.jpg');
% imwrite(Reconstruction,'explanation-reconstruction.jpg');
   