%% File used for the resorting of Widefield-SubScans to simulate less
%% projections obtained. Use ../MergeProjections/fct_mergeSubScanSelector.m
%% to merge the different subscans together in the end.
%% 15.04.2009 - first version

%% reset workspace, start timer
clear all;close all;clc;disp(['It`s now ' datestr(now) ]);tic;
currentdir=pwd; % save it for later, since we're cd'ing around

%% setup
UserID = 'e11126';
BeamTime = '2009b';

if isunix == 1 
    %beamline
        %whereamI = '/sls/X02DA/data';
    %slslc05
        whereamI = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da';
    PathToFiles = [ filesep 'Data10' filesep BeamTime];    
    SamplePath = fullfile( whereamI , UserID , PathToFiles );
    addpath([ whereamI filesep UserID filesep 'MATLAB'])
    addpath([ whereamI filesep UserID filesep 'MATLAB' filesep 'SRuCT']) 
else
    whereamI = 'S:';
    PathToFiles = [ 'SLS' filesep BeamTime ];
    SamplePath = fullfile(whereamI, PathToFiles);
    addpath('C:\Documents and Settings\haberthuer\My Documents\MATLAB')
    addpath('C:\Documents and Settings\haberthuer\My Documents\MATLAB\\SRuCT')
end

%% work this thing! http://is.gd/swoK
disp('pick directory of subscan to resort/slice. I`m adding "/tif" myself...');
%% chose BaseSubScanLocation
BaseSubScanLocation = uigetdir(SamplePath,...
    'Please locate the SubScan which I will then re-sort');
%%% chose BaseSubScanLocation
%%% set BaseSubScanLocation
% BaseSubScanLocation = 'S:\SLS\2008c\R108C21Ct_s2';
%%% set BaseSubScanLocation
[ tmp,BaseSubScanName,tmp ] = fileparts(BaseSubScanLocation);

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
DividingFactor= input('Please define the dividing factor for resorting [2]:');
if isempty(DividingFactor)
	DividingFactor = 2;
end
disp('---');

BaseSubScanLocation = [ BaseSubScanLocation filesep 'tif' ];
disp(['counting tif-files in "' BaseSubScanLocation '"' ]);
% filelist = dir([fileparts(BaseSubScanLocation) filesep '*.tif']);
filelist = dir([ BaseSubScanLocation filesep '*.tif']);
AmountOfFiles = length({filelist.name});
disp([ BaseSubScanName '/tif contains ' num2str(AmountOfFiles) ' tiff-Files,']);
NumProj = AmountOfFiles - NumDarks - NumFlats - NumFlats;
disp([ 'with ' num2str(NumDarks) ' darks and ' num2str(NumFlats) ' flats '...
    '(for each pre- and post-flats) we`ve acquired ' num2str(NumProj) ...
    ' projections.']);
disp('---');

%% output
DividedSubScanName = [ BaseSubScanName '_div' num2str(DividingFactor) ];
disp([ 'Im now copying the tif-files 1:' num2str(DividingFactor) ':' ...
    num2str(NumProj) ' from ' BaseSubScanName ' to consecutive projections of ' ...
    DividedSubScanName ]);

OutputPath = [ fileparts(fileparts(BaseSubScanLocation)) filesep ...
    DividedSubScanName filesep 'tif' ];
[s,mess,messid] = mkdir(OutputPath);

disp(['Copying ' num2str(NumDarks) ' Darks and ' num2str(NumFlats) ' Pre-Flats']);
w = waitbar(0,['Copying ' num2str(NumDarks) ' Darks and ' num2str(NumFlats) ' Pre-Flats']);
OutPutCounter = 1;
for ProjCounter = 1:NumDarks + NumFlats
    waitbar(OutPutCounter/(size(1:DividingFactor:NumProj,2) + NumDarks + NumFlats + NumFlats));
    CopyFromFile = [ BaseSubScanLocation filesep BaseSubScanName num2str(sprintf('%04d',ProjCounter)) '.tif' ];
    CopyToFile = [ OutputPath filesep DividedSubScanName num2str(sprintf('%04d',OutPutCounter)) '.tif' ];
    copyfile(CopyFromFile,CopyToFile);
    OutPutCounter = OutPutCounter + 1;
end
close(w);pause(0.001);
%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Copying original Projections ' num2str(NumDarks+NumFlats) ':' ...
    num2str(DividingFactor) ':' num2str(NumProj) ' to ' ...
    num2str(size(1:DividingFactor:NumProj,2)) ' renumbered Projections.']);
w = waitbar(0,['Copying ' num2str(size(1:DividingFactor:NumProj,2)) ' Projections']);
for ProjCounter = NumDarks + NumFlats + 1:DividingFactor:NumProj + NumDarks + NumFlats
    waitbar(OutPutCounter/(size(1:DividingFactor:NumProj,2) + NumDarks + NumFlats + NumFlats));
    CopyFromFile = [ BaseSubScanLocation filesep BaseSubScanName num2str(sprintf('%04d',ProjCounter)) '.tif' ];
    CopyToFile = [ OutputPath filesep DividedSubScanName num2str(sprintf('%04d',OutPutCounter)) '.tif' ];
    copyfile(CopyFromFile,CopyToFile);
    OutPutCounter = OutPutCounter + 1;
end
close(w);pause(0.001);
%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Copying ' num2str(NumFlats) ' Post-Flats']);
w = waitbar(0,['Copying ' num2str(NumFlats) ' Post-Flats']);
for ProjCounter = NumProj + NumDarks + NumFlats + 1:NumProj + NumDarks + NumFlats + NumFlats
    waitbar(OutPutCounter/(size(1:DividingFactor:NumProj,2) + NumDarks + NumFlats + NumFlats));
    CopyFromFile = [ BaseSubScanLocation filesep BaseSubScanName num2str(sprintf('%04d',ProjCounter)) '.tif' ];
    CopyToFile = [ OutputPath filesep DividedSubScanName num2str(sprintf('%04d',OutPutCounter)) '.tif' ];
    copyfile(CopyFromFile,CopyToFile);
    OutPutCounter = OutPutCounter + 1;
end
close(w);pause(0.001);
%%%%%%%%%%%%%%%%%%%%%%%%
disp('---');
disp(['From ' num2str(NumProj) ' original Projections I have now copied ' ...
    num2str(NumDarks) ' Darks, ' num2str(NumFlats) ' Pre-Flats, ' ...
    num2str(OutPutCounter-NumDarks-NumFlats-NumFlats) ' Projections (spaced ' ...
    'by ' num2str(DividingFactor) ') and ' num2str(NumFlats) ' Post-Flats ' ...
    'to ' OutputPath ]);

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

