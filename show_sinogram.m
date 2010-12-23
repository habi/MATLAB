clc;
clear;
close all;

InterleavedImage = imread('/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_sinog/R108C60_22_20x_A_conc_sino_/R108C60_22_20x_A_conc_sino_0512.sin.tif');
figure;
    imshow(InterleavedImage);
    title(num2str(size(InterleavedImage)));
for i=1:size(InterleavedImage,1)/10
    Sinogram(i,:)=InterleavedImage(10*i+1,:);
end
figure;
    imshow(Sinogram);
    title(num2str(size(Sinogram)));
imwrite(Sinogram,'/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_sinog/R108C60_22_20x_A_conc_sino_/R108C60_22_20x_A_conc_sino_0512.sin2.tif');