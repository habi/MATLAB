%% Pick a File and open the DMP
clc;clear all;close all;

if isunix
    addpath('/sls/X02DA/data/e11126/MATLAB/SRuCT');
else
    addpath('P:\MATLAB\SRuCT');
end

%[ FileName, PathName] = uigetfile('*.DMP','Select the DMP-file to show');
%disp('reading...')
%DMP = readDumpImage([PathName FileName]);

%File='R:\SLS\Diss\L-VII-12_B10501.sin.DMP';
File='r:\SLS\Diss\L-XXI-18_B50501.sin.DMP';
%File='R:\SLS\Diss\R108C36C_B3-mrg\sin\R108C36C_B3-mrg0501.sin.DMP';
DMP = readDumpImage(File);

%% SINOGRAM
disp('displaying...')
figure
    imshow(DMP,[]);

min(min(DMP))
max(max(DMP))
DMP = DMP - min(min(DMP));
DMP = DMP / max(max(DMP));
min(min(DMP))
max(max(DMP))
imwrite(DMP,[File '.png']);    
 