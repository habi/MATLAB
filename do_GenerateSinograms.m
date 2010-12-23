clear;
clc;
close all;

%% Set Parameters
Filename = 'R108C60_22_20x_D_conc';
%function h_GenerateSinograms(Filename,maxImgNum,SinRow)
h_GenerateSinograms(Filename,1501,256);
h_GenerateSinograms(Filename,1501,512);
h_GenerateSinograms(Filename,1501,768);

Filename = 'R108C60_22_20x_A_conc';
%function h_GenerateSinograms(Filename,maxImgNum,SinRow)
h_GenerateSinograms(Filename,3001,256);
h_GenerateSinograms(Filename,3001,512);
h_GenerateSinograms(Filename,3001,768);
