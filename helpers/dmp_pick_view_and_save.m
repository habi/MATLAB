%% Pick a File and open the DMP
clc;clear all;close all;
warning off Images:initSize:adjustingMag % suppress the warning about big images, they are still displayed correctly, just a bit smaller..

if isunix
    addpath('/sls/X02DA/data/e11126/MATLAB/SRuCT');
else
    addpath('P:\MATLAB\SRuCT');
end

[ FileName, PathName] = uigetfile('*.DMP','Select the DMP-file to show','/sls/X02DA/data/e11126');
disp('reading...')

DMP = mat2gray(readDumpImage([PathName FileName]));

disp('displaying...')
figure
    imshow(DMP,[]);
    title([ FileName ', Size: ' num2str(size(DMP,1)) 'x' num2str(size(DMP,2)) 'px.'],'interpreter','none')
    
disp(['The chosen DMP has a size of ' num2str(size(DMP,1)) 'x' num2str(size(DMP,2)) 'px.' ])
disp(['Writing to ' PathName filesep FileName '.png' ])
imwrite(DMP,[ PathName filesep FileName '.png'])