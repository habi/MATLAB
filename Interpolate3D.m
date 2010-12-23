clc,clear all,close all;
factor = 5;
x = 1:factor;
y = 1:factor;
z = 1:2;
% v(:,:,1) = magic(factor);
v(:,:,1) = rand(factor);
% v(:,:,2) = magic(factor)';
v(:,:,2) = rand(factor);
[xi,yi,zi] = meshgrid(1:factor,1:factor,1:.5:2);
vi = interp3(x,y,z,v,xi,yi,zi);
    xslice = [];
    yslice = [];
    zslice = [1:.5:2];

figure
    slice(xi,yi,zi,vi,xslice,yslice,zslice)
	colormap jet
    
figure
	subplot(131)
        imshow(vi(:,:,1),[])
        title('Slice 1')
	subplot(132)
        imshow(vi(:,:,round(end/2)),[])
        title('Interpolated Slice')
	subplot(133)
        imshow(vi(:,:,end),[])
        title('Slice 2')        

figure
	subplot(131)
    	imshow(vi(:,:,1),[])
        title('Slice 1')
	subplot(132)
        imshow(mean(v,3),[])
        title('Averaged Slice')
    subplot(133)
    	imshow(vi(:,:,end),[])
        title('Slice 2')

disp('Difference A between Interpolation (vi(:,:,2)) and Average of the two slices (mean(v,3))')
A=vi(:,:,round(end/2))-mean(v,3)