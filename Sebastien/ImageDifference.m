clc;clear all;
a=imread('cameraman.tif');
b=imnoise(a);
c=imabsdiff(a,b);
error=sum(sum(c));

figure
    subplot(131)
        imshow(a,[])
	subplot(132)
        imshow(b,[])
    subplot(133)
        imshow(c,[])        
        title(error);