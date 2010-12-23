clc;
clear;
close all;

size=100;
int=5;

img=zeros(size);
img(1/6*size-int:1/6*size+int,1/6*size-int:1/6*size+int)=1;
img(2/6*size-int:2/6*size+int,2/6*size-int:2/6*size+int)=.8;
img(3/6*size-int:3/6*size+int,3/6*size-int:3/6*size+int)=.6;
img(4/6*size-int:4/6*size+int,4/6*size-int:4/6*size+int)=.4;
img(5/6*size-int:5/6*size+int,5/6*size-int:5/6*size+int)=.2;

sinogram=radon(img,0:360);

reconstruction=iradon(sinogram,0:360);

figure
    subplot(221)
        imshow(img,[])
        title('Original Image')
        axis on tight        
    subplot(2,2,[3 4])
        imshow(sinogram,[])
        title('Sinogram')
         axis on tight               
    subplot(222)
        imshow(reconstruction,[])
        title('Reconstruction')
               axis on tight        
               
               
figure
    imshow(img,[])
    axis on tight

print -deps -r300 /afs/psi.ch/user/h/haberthuer/MATLAB/img/dirac-original
close

figure
    imshow(sinogram,[])
    axis on tight  

print -deps -r300 /afs/psi.ch/user/h/haberthuer/MATLAB/img/dirac-sinogram
close

figure
    imshow(reconstruction,[])
    axis on tight 

print -deps -r300 /afs/psi.ch/user/h/haberthuer/MATLAB/img/dirac-reconstructuion
close



sinogram = sinogram - min(min(sinogram));
sinogram = sinogram ./ max(max(sinogram));

imwrite(img,'/afs/psi.ch/user/h/haberthuer/MATLAB/img/dirac-original.jpg')
imwrite(sinogram,'/afs/psi.ch/user/h/haberthuer/MATLAB/img/dirac-sinogram.png')
imwrite(reconstruction,'/afs/psi.ch/user/h/haberthuer/MATLAB/img/dirac-reconstruction.png')
