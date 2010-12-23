clc;clear;close all;

I = imread('http://habi.gna.ch/tmp/P10001.bmp');
I = imread('/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/R108C60_22202_A_ct/tif/R108C60_22202_A_ct0007.tif');
I = (I(:,:,1));

[M N] = size(I);

I_transform = imread('http://habi.gna.ch/tmp/P11111.bmp');
I_transform = imread('/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/R108C60_22202_A_rt/tif/R108C60_22202_A_rt0007.tif');
I_transform = (I_transform(:,:,1));

initial_scale=[pi/12 1 1];

[scale,Fval]=fminsearch('rescale2',initial_scale,[],I,I_transform);
disp(Fval);

u=scale(1);
dx=scale(2);
dy=scale(3);

Trotation=[cos(u) sin(u) 0;-sin(u) cos(u) 0;0 0 1;];
Ttranslation=[1 0 0;0 1 0;dx dy 1;];
T=Trotation*Ttranslation;

Tform=maketform('affine',T)
I_aligned=imtransform(I_transform,Tform,'Xdata',[1 N],'Ydata',[1 M]);

figure
subplot(131); imshow(I,[]);
title('original')
subplot(132); imshow(I_transform,[]);
title('transformed image')
subplot(133); imshow(I_aligned,[]);
title('aligned')

figure; imshow(I,[]);

figure; imshow(I_transform,[]);

figure; imshow(I_aligned,[]);
