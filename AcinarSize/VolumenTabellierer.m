%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reads DICOM-Files of the acini from each day 60-sample and extracts their
% volume to an XLS-File

clc
clear all
close all


Sample = {'60B','60C','60D','60E'};
Beamtime = {'2010c','2010a','2009f','2009f'};

%% Construct Sample Names. I wish we had used a consistent
%% Sample-Naming-Scheme...
for i =1:length(Sample)
    if i>1  
        p='mrg';
        q='-mrg';        
    else
        p=[];
        q='_mrg';
    end
    if i<3
        r = '_B1';
    else
        r = 't';
    end
    SampleName{i} = ['R108C',Sample(i),r,q];
    SamplePath{i} = fullfile('r:\sls',cell2mat(Beamtime(i)),p,cell2mat(SampleName{i}));
end

%% Delete file from prior runs.
DataFileName = 'AcinarVolumes.xls';
delete(fullfile(pwd,DataFileName))

%% Iterate through Samples
for SampleCounter=1:size(SamplePath,2)
    disp([ 'Counting DICOM-Files in ' SamplePath{SampleCounter} ]);
    filelist = dir([SamplePath{SampleCounter} filesep '*.dcm']);
    NumberOfDICOMFiles(SampleCounter) = size(filelist,1);
    disp([ 'Found ' num2str(NumberOfDICOMFiles(SampleCounter)) ' DICOM-files']);
    for i=1:NumberOfDICOMFiles(SampleCounter)
        %disp([ '(' num2str(i) '/' num2str(NumberOfDICOMFiles(SampleCounter)) ') Extracting Data of ' filelist(i).name ]);
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
    disp(['Writing data to ',fullfile(pwd,DataFileName)])
    warning('off', 'MATLAB:xlswrite:AddSheet');
    xlswrite(DataFileName,cellstr('Acinusgrössen, bestimmt mit MeVisLab'),cell2mat(SampleName{SampleCounter}),'E1');
    xlswrite(DataFileName,cellstr(SamplePath{SampleCounter}),cell2mat(SampleName{SampleCounter}),'A1');
    xlswrite(DataFileName,cellstr('Acinus'),cell2mat(SampleName{SampleCounter}),'A2');
    xlswrite(DataFileName,cellstr('Volume [ul]'),cell2mat(SampleName{SampleCounter}),'B2');
    xlswrite(DataFileName,AcinusList',cell2mat(SampleName{SampleCounter}),'A3');
    status = xlswrite(DataFileName,Volume',cell2mat(SampleName{SampleCounter}),'B3');
    clear AcinusList
    clear Volume
end

disp('')
disp(['Written all volumes to ',fullfile(pwd,DataFileName)])

disp('Finished!')