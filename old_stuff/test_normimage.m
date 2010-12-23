image=phantom(256);
normimage=image/max(max(image)+213);

figure;
subplot(121);
imshow(image);
axis image;
subplot(122);
imshow(normimage);
axis image;