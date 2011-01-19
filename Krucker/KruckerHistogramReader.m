% MATLAB-Script to read the Histograms written with
% /MeVisLab/2010/Krucker/Acinussegmentation_*.mlab
% The histograms are saved as text files in the directories
% D:\SLS\2010b\M251* and are then read from here
clc;clear all;
close all;

%% Sample definition
Histogram(1).dir = 'd:\SLS\2010b\M251-090S7_';
Histogram(2).dir = 'd:\SLS\2010b\M251-102V7_';
Histogram(3).dir = 'd:\SLS\2010b\M251-115O7_';
Histogram(4).dir = 'd:\SLS\2010b\M251-N01_';

%% extracting data
for i=1:length(Histogram)
    % reading directories, finding histogram.txt files
    disp([ 'counting .txt-Files in ' Histogram(i).dir ]);
    Histogram(i).list = dir([ Histogram(i).dir filesep '*.txt']);
    disp([ 'We found ' num2str(length(Histogram(i).list)) ' .txt-Files in ' Histogram(i).dir ]);
    % extracting info from txt-files
    for k=1:length(Histogram(i).list)
        Histogram(i).rawdata(k) = importdata([Histogram(i).dir filesep Histogram(i).list(k).name], ' ',1);
        Histogram(i).info(k) = Histogram(i).rawdata(k).textdata;
        tmp = textscan(char(Histogram(i).info(k)),'%s'); % split first line of txt files to read out info
        Histogram(i).name = tmp{1}(2); % second string is name.xsize.ysize.zsize
        Histogram(i).name = textscan(char(Histogram(i).name),'%100[^._]'); % trim to only name
        Histogram(i).voxels(k) = str2double(tmp{1}(5)); % fifth string is voxel count
        Histogram(i).voxelsize(k) = str2double(tmp{1}(11)); % eleventh string is voxel size
        disp(['Extracted info for ' char(Histogram(i).name{1}) ', segment ' num2str(k)])
        disp(['Voxels(' char(Histogram(i).name{1}) ',segment ' num2str(k) '): ' num2str(Histogram(i).voxels(k)) ])
        disp(['Voxel size(' char(Histogram(i).name{1}) ',segment ' num2str(k) '): ' num2str(Histogram(i).voxelsize(k)) ])
    end
    disp('---');
end

%% Normalizing to Voxel Volume
for i=1:length(Histogram)
    for k=1:length(Histogram(i).list)
        Histogram(i).rawdata(k).data(:,2)=Histogram(i).rawdata(k).data(:,2)/Histogram(i).voxels(k);
    end
end

figure
for i=1:length(Histogram)
    subplot(1,4,i)
        for k=1:length(Histogram(i).list)
            semilogy(Histogram(i).rawdata(k).data(:,1),Histogram(i).rawdata(k).data(:,2))
            hold on         
        end
        title(char(Histogram(i).name{1}),'Interpreter','none')
end
% matlab2tikz('krucker_logarithmic.tex')

figure
for i=1:length(Histogram)
    subplot(1,4,i)
        for k=1:length(Histogram(i).list)
            plot(Histogram(i).rawdata(k).data(:,1),Histogram(i).rawdata(k).data(:,2))
            hold on
        end
        title(char(Histogram(i).name{1}),'Interpreter','none')        
end
%matlab2tikz('krucker.tex')

for i=1:length(Histogram)
    for k=1:length(Histogram(i).list)
        Writing=Histogram(i).rawdata(k).data;
        Writing
        disp('to xls-File')
        disp('---')
        xlswrite([ 'Histogram' char(Histogram(i).name{1}) '.xls'],Histogram(i).rawdata(k).data,k)
    end
end