%Convex Hull Generator
% Reads Images and calcuates Fraction of Total Volume to Airway Volume.

% First Version 26.02.2010

clc;clear all;close all;

BasePath = 'R:\SLS\2010a\mrg';
SampleName = 'R108C60C';
Stack = '_B3';
RecFolder = 'rec_8bit';
SliceNumber = 1024;

Slice = imread([ BasePath filesep SampleName Stack '-mrg' filesep RecFolder ...
    filesep SampleName Stack '-mrg' num2str(sprintf('%04d',SliceNumber)) ...
    '.rec.8bit.tif' ]);

Threshold = graythresh(Slice);
BinarizedSlice = im2bw(Slice,Threshold);
% Hull = regionprops(double(BinarizedSlice),'ConvexImage')

se = strel('disk',100);
Hull = imclose(Hull,se);

figure
    subplot(131)
        imshow(Slice,[]);
    subplot(132)
        imshow(BinarizedSlice,[]);
    subplot(133)
    	imshow(Hull,[]);
%     	imshow(Hull.ConvexImage);
    

