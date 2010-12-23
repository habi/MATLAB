clear;
clc;
Img=Phantom(128);

PaddedImg = h_PadImage(Img,128,160);

figure(1);
    imagesc(Img);
    axis image;
figure(2);
    imagesc(PaddedImg);
    axis image

figure(3);
    subplot(1,2,1)
        imagesc(Img);
        axis image;
	subplot(1,2,1)
        imagesc(PaddedImg);
        axis image;    