clc;
clear all;

SampleWidth=2048;
DetectorWidth=1024;
Overlap=150;
MaximalQuality=100;
MinimalQuality=60;
NumberOfProjections = fct_segmentreducer(SampleWidth,DetectorWidth,Overlap,MinimalQuality,MaximalQuality)

ProjectionsSize=size(NumberOfProjections)

disp('been there, done that!')