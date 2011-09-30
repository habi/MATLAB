%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reads Histogram of Pooled Volumes
clc,clear all,close all;

data=xlsread('u:\Gruppe_Schittny\doc\David\AcinarVolumes.xls','Pooled');
data=data(:,1);
max(data)
min(data)
figure
   hist(data,20)