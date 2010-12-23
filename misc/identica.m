clc;clear all;close all

data=xlsread(uigetfile('*.xls','Select the XLS-file'));
interval = 25;
dents=data(1:interval:end,1)
days=data(1:interval:end,9)
data

figure
    plot(days,dents)
    hold on

addpath('C:\Documents and Settings\haberthuer\My Documents\MATLAB\matlab2tikz')
matlab2tikz('dents.tex')
