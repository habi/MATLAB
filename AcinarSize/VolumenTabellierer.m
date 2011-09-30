%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reads DICOM-Files of the acini from each day 60-sample and extracts their
% volume to an XLS-File

clc
clear all
close all

SamplePath{1} = 'd:\SLS\2010c\R108C60B_B1_mrg\';
SamplePath{2} = 'd:\SLS\2010a\mrg\R108C60C_B1-mrg\';
SamplePath{3} = 'd:\SLS\2009f\mrg\R108C60Dt-mrg\';
SamplePath{4} = 'd:\SLS\2009f\mrg\R108C60Et-mrg\';

%% Iterate through Samples
for SampleCounter=1:size(SamplePath,2)
    disp([ 'Counting DICOM-Files in ' SamplePath{SampleCounter} ]);
    filelist = dir([SamplePath{SampleCounter} filesep '*.dcm']);
    NumberOfDICOMFiles(SampleCounter) = size(filelist,1);
    disp([ 'Found ' num2str(NumberOfDICOMFiles(SampleCounter)) ' DICOM-files']);
    for i=1:NumberOfDICOMFiles(SampleCounter)
        %disp([ '(' num2str(i) '/' num2str(NumberOfDICOMFiles(SampleCounter)) ') Extracting Data of ' filelist(i).name ]);
        %% Extract SampleName
        SampleNameStartPointer(SampleCounter) = regexp(SamplePath{SampleCounter}, 'R108', 'once'); % find first occurrence of "R108"
        SampleNameEndPointer = regexp(SamplePath{SampleCounter}, 'mrg'); % finds *all* occurrences of "mrg"
        SampleNameEndPointer(SampleCounter) = SampleNameEndPointer(end); %saves *last* occurrence to EndPointer
        SampleName{SampleCounter}=SamplePath{SampleCounter}(SampleNameStartPointer(SampleCounter):SampleNameEndPointer(SampleCounter)+2);
        AcinusName{i}=[SamplePath{SampleCounter} filelist(i).name];
        % Extract AcinusName
        AcinusStartPointer = regexp(AcinusName{1}, 'acinus', 'once');
        AcinusEndPointer = regexp(AcinusName{i}, '.volume', 'once');
        AcinusNumber = AcinusName{i}(AcinusStartPointer+6:AcinusEndPointer-1); % remove "acinus", so we can format the number nicely
        AcinusNumber = (sprintf('%02d',str2num(AcinusNumber))); % format string to number and pad with zero if necessary
        AcinusList{i} = [ 'acinus' AcinusNumber ];
        % Extract Volume from Filename
        VolumeStartPointer = regexp(AcinusName{i}, 'volume', 'once');
        VolumeEndPointer = regexp(AcinusName{i}, 'pixelsize', 'once');
        Volume{i} = AcinusName{i}(VolumeStartPointer+6:VolumeEndPointer-2);
    end
    [status, message]=xlswrite('AcinarVolumes.xls',cellstr(SamplePath{SampleCounter}),SampleName{SampleCounter},'A1');
    [status, message]=xlswrite('AcinarVolumes.xls',cellstr('Acinus'),SampleName{SampleCounter},'A2');
    [status, message]=xlswrite('AcinarVolumes.xls',cellstr('Volume [ul]'),SampleName{SampleCounter},'B2');
    [status, message]=xlswrite('AcinarVolumes.xls',AcinusList',SampleName{SampleCounter},'A3');
    [status, message]=xlswrite('AcinarVolumes.xls',Volume',SampleName{SampleCounter},'B3');
    clear AcinusList
    clear Volume
end

disp('Finished!')