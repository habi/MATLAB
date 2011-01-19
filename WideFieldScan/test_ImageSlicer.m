clc;
clear all;
close all;

InputImage       = imnoise(phantom(256),'gaussian');
AmountOfSubScans = 3;
DetectorWidth    = 10;
Overlap_px       = 10;
showImg          = 1;

SubScans=fct_ImageSlicer(InputImage,AmountOfSubScans,DetectorWidth,Overlap_px,showImg);