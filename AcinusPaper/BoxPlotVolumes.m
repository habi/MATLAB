clc;clear all;close all;
%%%%%%%%%%%%%%% Volumes %%%%%%%%%%%%%%% 
FileName= 'p:\doc\#R\AcinusPaper\_TotalVolumes.csv';
Data = xlsread(FileName);

figure
    boxplot(Data(:,2:6),...%
        'labels',{'04','10','21','36','60'},...
        'notch','on')

matlab2tikz('BoxPlot.tex')

%%%%%%%%%%%%%%% Normalized %%%%%%%%%%%%%%% 
clear all;
FileName= 'p:\doc\#R\AcinusPaper\_TotalVolumesNormalized.csv';
Data = xlsread(FileName);

size(Data)

figure
    boxplot(Data(:,2:6),...%
        'labels',{'04','10','21','36','60'},...
        'notch','on')

matlab2tikz('BoxPlotNormalized.tex')