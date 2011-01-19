clc;clear all;close all;

%load projections
Projection1 = imread('s:\SLS\2008c\R108C21Cb_s1\tif\R108C21Cb_s13358.tif'); 
Projection2 = imread('s:\SLS\2008c\R108C21Cb_s2\tif\R108C21Cb_s23358.tif');
Projection3 = imread('s:\SLS\2008c\R108C21Cb_s3\tif\R108C21Cb_s33358.tif');

DarkImage1 = imread('s:\SLS\2008c\R108C21Cb_s1\tif\R108C21Cb_s10001.tif');
FlatImage1 = imread('s:\SLS\2008c\R108C21Cb_s1\tif\R108C21Cb_s10015.tif');
DarkImage2 = imread('s:\SLS\2008c\R108C21Cb_s2\tif\R108C21Cb_s20001.tif');
FlatImage2 = imread('s:\SLS\2008c\R108C21Cb_s2\tif\R108C21Cb_s20015.tif');
DarkImage3 = imread('s:\SLS\2008c\R108C21Cb_s3\tif\R108C21Cb_s30001.tif');
FlatImage3 = imread('s:\SLS\2008c\R108C21Cb_s3\tif\R108C21Cb_s30015.tif');

CP1 = log(double(FlatImage1)) - log(double(Projection1-DarkImage1));
CP2 = log(double(FlatImage2)) - log(double(Projection2-DarkImage2));
CP3 = log(double(FlatImage3)) - log(double(Projection3-DarkImage3));

figure
    subplot(231)
    	imshow(Projection1,[])
    subplot(232)
        imshow(Projection2,[])
    subplot(233)
        imshow(Projection3,[])
 	subplot(234)
        imshow(CP1,[])
 	subplot(235)
         imshow(CP2,[])
 	subplot(236)
         imshow(CP3,[])

imwrite(CP1,'c:\Documents and Settings\haberthuer\Desktop\CP-R108C21Cb_s13358.tif','Compression','none');
imwrite(CP2,'c:\Documents and Settings\haberthuer\Desktop\CP-R108C21Cb_s23358.tif','Compression','none');
imwrite(CP3,'c:\Documents and Settings\haberthuer\Desktop\CP-R108C21Cb_s33358.tif','Compression','none');
disp('been there, done that!')