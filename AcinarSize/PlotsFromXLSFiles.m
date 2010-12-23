%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parster for the Excel-Files generated from the Acinar Size Networks in
% p:\doc\MeVisLab-Networks\2010\AcinarTreeExtraction\ The Excel-Files are
% in the directory p:\doc\#Tables\AcinarTreeExtraction\ and will be read
% from there
%
% First version 23.12.2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;clear all;close all;

Days = [4,10,21,36,60];
Suffix = [{'At'},{'C'},{'D'},{'A'},{'B'}];
Range = [ {'B4:B92'},{'B4:B91'},{'B4:B127'},{'B4:B93'},{'B4:B37'}];

for i = 1:5
    Data(i).FileName = cell2mat(['P:\doc\#Tables\AcinarTreeExtraction\' num2str(sprintf('%02d',Days(i))) ...
        '\R108C' num2str(sprintf('%02d',Days(i))) Suffix(i) ]);
    %disp(Data(i).FileName)
end

for i = 1:5
    disp(['reading XLS-File ' Data(i).FileName ])
    Data(i).Volumes = xlsread(Data(i).FileName, 1, cell2mat(Range(i)));
end

% figure
%     for i=1:5
%         subplot(5,1,i)
%         plot(Data(i).Volumes)
%         title([ 'Tag ' num2str(Days(i)) ])
%     end
 
figure
    range = 0.1
    for i=1:5
        subplot(5,3,3*i-2)
        plot(Data(i).Volumes.*(Data(i).Volumes<range))
        title(num2str(range))
    end
    range = 0.2
    for i=1:5
        subplot(5,3,3*i-1)
        plot(Data(i).Volumes.*(Data(i).Volumes<range))
        title(num2str(range))
    end    
    range = 0.3
    for i=1:5
        subplot(5,3,3*i)
        plot(Data(i).Volumes.*(Data(i).Volumes<range))
        title(num2str(range))
    end    
   