orig=phantom(256);
%orig = double(imread('/afs/psi.ch/user/h/haberthuer/images/phantom512.png','png'));
interp = h_SplitInterpolate(orig,3,2); % 3 and 2 are just dummy operators for now!

screensize = get(0,'ScreenSize');
figure('Position',[20 screensize(4)/3 screensize(3)/3 screensize(4)/3]);
subplot(1,2,1);
imagesc(orig');
title('original');
axis equal;
subplot(1,2,2);
imagesc(interp);
title('middle is interpolated');
axis equal;
