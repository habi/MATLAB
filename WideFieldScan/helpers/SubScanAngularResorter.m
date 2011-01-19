%% File used for the angular resorting of Widefield-SubScans to simulate
%% differing start angle. Settable by "skip".
%% Use ../MergeProjections/fct_mergeSubScanSelector.m to merge the 
%% different subscans together in the end.
%% 23.04.2009 - first version

%% reset workspace, start timer
clear all;close all;clc;disp(['It`s now ' datestr(now) ]);tic;
currentdir=pwd; % save it for later, since we're cd'ing around

%% setup
UserID = 'e11126';
BeamTime = '2009b';
Data = 'Data10';

if isunix == 1 
    %beamline
        %whereamI = '/sls/X02DA/data';
    %slslc05
        whereamI = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da';
    PathToFiles = [ filesep Data filesep BeamTime];    
    SamplePath = fullfile( whereamI , UserID , PathToFiles );
    addpath([ whereamI filesep UserID filesep 'MATLAB'])
    addpath([ whereamI filesep UserID filesep 'MATLAB' filesep 'SRuCT']) 
else
    whereamI = 'S:';
    PathToFiles = [ 'SLS' filesep BeamTime ];
    SamplePath = fullfile(whereamI, PathToFiles);
    addpath('P:\MATLAB')
    addpath('P:\MATLAB\SRuCT')
end

%% work this thing! http://is.gd/swoK
disp('pick directory of subscan to perform the angular resort. I`m adding "/tif" myself...');
%% chose OriginalSubScanLoaction
% % % OriginalSubScanLoaction = uigetdir(SamplePath,...
% % %     'Please locate the SubScan which I will then re-sort');
OriginalSubScanLoaction = 'S:\SLS\2008c\mrg\R108C21Cb_mrg'
%%% set OriginalSubScanLoaction
[ tmp,BaseSubScanName,tmp ] = fileparts(OriginalSubScanLoaction);

NumDarks = input('how many darks? [5]:');
if isempty(NumDarks)
    NumDarks = 5;
end
NumFlats = input('how many flats? [20]:');
if isempty(NumFlats)
    NumFlats = 20;
end
disp('i`m assuming pre- and post-flats!');
disp('---');

ResortValue = input('Please tell my by how many projections I should shift the projections [10]:');
if isempty(ResortValue)
	ResortValue = 10;
end
disp('---');

OriginalSubScanLoaction = [ OriginalSubScanLoaction filesep 'tif' ];
disp(['counting tif-files in "' OriginalSubScanLoaction '"' ]);
filelist = dir([ OriginalSubScanLoaction filesep '*.tif']);
TotalAmountOfFiles = length({filelist.name});
disp([ BaseSubScanName '/tif contains totally ' num2str(TotalAmountOfFiles) ' tiff-Files,']);
NumProj = TotalAmountOfFiles - NumDarks - NumFlats - NumFlats;
disp([ 'with ' num2str(NumDarks) ' darks and ' num2str(NumFlats) ' flats '...
    '(for each pre- and post-flats) we`ve acquired ' num2str(NumProj) ...
    ' projections.']);
disp('---');

disp([ 'I am shifting the projections by ' num2str(ResortValue) '.'])
disp([ 'Projection 1 will be Projection ' num2str(1+ResortValue) ', Projection ' ...
    num2str(NumProj) ' will be Projection ' num2str(NumProj+ResortValue) ...
    ' (hence wrap around to being Projection ' num2str(ResortValue) ').']);
disp('---');

%% output
ResortedSubScanName = [ BaseSubScanName '_shft' num2str(ResortValue) ];
disp([ 'Im now copying the tif-files from ' BaseSubScanName ' to resorted '...
    ' projections into ' ResortedSubScanName ]);

OutputPath = [ fileparts(fileparts(OriginalSubScanLoaction)) filesep ...
    ResortedSubScanName filesep 'tif' ];
[s,mess,messid] = mkdir(OutputPath);
 
% disp(['Copying ' num2str(NumDarks) ' Darks and ' num2str(NumFlats) ' Pre-Flats']);
% w = waitbar(0,['Copying ' num2str(NumDarks) ' Darks and ' num2str(NumFlats) ' Pre-Flats']);
% OutPutCounter = 1;
% for ProjCounter = 1:NumDarks + NumFlats
%     waitbar(OutPutCounter/(size(1:ResortValue:NumProj,2) + NumDarks + NumFlats + NumFlats));
%     CopyFromFile = [ OriginalSubScanLoaction filesep BaseSubScanName num2str(sprintf('%04d',ProjCounter)) '.tif' ];
%     CopyToFile = [ OutputPath filesep ResortedSubScanName num2str(sprintf('%04d',OutPutCounter)) '.tif' ];
%     copyfile(CopyFromFile,CopyToFile);
%     OutPutCounter = OutPutCounter + 1;
% end
% close(w);pause(0.001);
% %%%%%%%%%%%%%%%%%%%%%%%%
% disp(['Copying original Projections ' num2str(NumDarks+NumFlats) ':' ...
%     num2str(ResortValue) ':' num2str(NumProj) ' to ' ...
%     num2str(size(1:ResortValue:NumProj,2)) ' renumbered Projections.']);
% w = waitbar(0,['Copying ' num2str(size(1:ResortValue:NumProj,2)) ' Projections']);
% for ProjCounter = NumDarks + NumFlats + 1:ResortValue:NumProj + NumDarks + NumFlats
%     waitbar(OutPutCounter/(size(1:ResortValue:NumProj,2) + NumDarks + NumFlats + NumFlats));
%     CopyFromFile = [ OriginalSubScanLoaction filesep BaseSubScanName num2str(sprintf('%04d',ProjCounter)) '.tif' ];
%     CopyToFile = [ OutputPath filesep ResortedSubScanName num2str(sprintf('%04d',OutPutCounter)) '.tif' ];
%     copyfile(CopyFromFile,CopyToFile);
%     OutPutCounter = OutPutCounter + 1;
% end
% close(w);pause(0.001);
% %%%%%%%%%%%%%%%%%%%%%%%%
% disp(['Copying ' num2str(NumFlats) ' Post-Flats']);
% w = waitbar(0,['Copying ' num2str(NumFlats) ' Post-Flats']);
% for ProjCounter = NumProj + NumDarks + NumFlats + 1:NumProj + NumDarks + NumFlats + NumFlats
%     waitbar(OutPutCounter/(size(1:ResortValue:NumProj,2) + NumDarks + NumFlats + NumFlats));
%     CopyFromFile = [ OriginalSubScanLoaction filesep BaseSubScanName num2str(sprintf('%04d',ProjCounter)) '.tif' ];
%     CopyToFile = [ OutputPath filesep ResortedSubScanName num2str(sprintf('%04d',OutPutCounter)) '.tif' ];
%     copyfile(CopyFromFile,CopyToFile);
%     OutPutCounter = OutPutCounter + 1;
% end
% close(w);pause(0.001);
% %%%%%%%%%%%%%%%%%%%%%%%%
% disp('---');
% disp(['From ' num2str(NumProj) ' original Projections I have now copied ' ...
%     num2str(NumDarks) ' Darks, ' num2str(NumFlats) ' Pre-Flats, ' ...
%     num2str(OutPutCounter-NumDarks-NumFlats-NumFlats) ' Projections (spaced ' ...
%     'by ' num2str(ResortValue) ') and ' num2str(NumFlats) ' Post-Flats ' ...
%     'to ' OutputPath ]);

%% finish
disp('I`m done with all you`ve asked for...');disp(['It`s now ' datestr(now) ]);
zyt=toc;sekunde=round(zyt);minute = round(sekunde/60);stunde = round(minute/60);
if stunde >= 1
    minute = minute - 60*stunde;
    sekunde = sekunde - 60*minute - 3600*stunde;
    disp(['It took me approx ' num2str(round(stunde)) ' hours, ' ...
        num2str(round(minute)) ' minutes and ' num2str(round(sekunde)) ...
        ' seconds to perform the given task' ]);
else
    minute = minute - 60*stunde;
    sekunde = sekunde - 60*minute;
    disp(['It took me approx ' num2str(round(minute)) ' minutes and ' ...
        num2str(round(sekunde)) ' seconds to perform given task' ]);
end
cd(currentdir);
helpdlg('I`m done with all you`ve asked for...','Phew!');

