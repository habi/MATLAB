clear;
close all;
clc;
Phantom=phantom(256);
RotCorrPhantom=h_CorrectRotCenter(Phantom,size(Phantom,1));
% RotCorrPhantom=h_CorrectRotCenter(Phantom,0);
figure;
    imshow(RotCorrPhantom,[]);
    axis image
    title(['Phantom: ' num2str(size(Phantom)) ' / Corrected Phantom: ' num2str(size(RotCorrPhantom))]);