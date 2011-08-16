clc;clear all;close all;
%%%%%%%%%%%%%%% Volumes %%%%%%%%%%%%%%% 
FileName= 'p:\doc\#R\AcinusPaper\TotalVolumes.csv';
Data = xlsread(FileName);


%%
% Data = Data./nanmean(Data(:,2));
% StefansIncrease = [ 1.000000 1.665574 3.436066 6.760656 9.718033];
%%

X = [04 10 21 36 60];
width = [202 202 203 201 149]/20; % scale widths with Number of Acini
width = [5 5 10 10 10]; % arbitrary scale
width = [5 5 5 5 5]; % arbitrary scale

figure
    boxplot(Data(:,2:6), 'positions', X, 'labels', X,...
        'notch','on',...
        'widths',width)
    % hold on
    % plot(X,StefansIncrease) 
    
matlab2tikz('BoxPlot.tex')

%%%%%%%%%%%%%%% Normalized %%%%%%%%%%%%%%% 
clear Data
FileName= 'p:\doc\#R\AcinusPaper\TotalVolumesNormalized.csv';
Data = xlsread(FileName);

size(Data)

figure
    boxplot(Data(:,2:6), 'positions', X, 'labels', X,...
        'notch','on',...
        'widths',width)

matlab2tikz('BoxPlotNormalized.tex')