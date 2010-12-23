close all
clear
clc
Image = imread('board.tif');
figure
    subplot(131)
        imshow(Image,[])
    subplot(132)
        imagesc(Image)
	subplot(133)
        image(Image)