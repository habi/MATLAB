function [err] = rescale2(scale,I,I_transform);

% This is a comment to see if comments are marked in the Listing (for \Latex\dots)

[M N]=size(I);

u=scale(1);
dx=scale(2);
dy=scale(3)

Trotation=[cos(u) sin(u) 0; -sin(u) cos(u) 0; 0 0 1;];
Ttranslation=[1 0 0;0 1 0; dx dy 1;];
T=Trotation*Ttranslation

Tform=maketform('affine',T);
I_aligned=imtransform(I_transform,Tform,'Xdata',[1 N],'Ydata',[1 M]);

err=-abs(corr2(I_aligned,I));

disp('Been there, done that!')
end