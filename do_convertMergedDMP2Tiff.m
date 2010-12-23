%% definition
%% do_convertDMP2Tiff
%% reads a bunch of DMPs from an input-directory and writes them out as
%% tiffs into the outputdirectory

%% 10.07.2008 - initial version

%% init
clear;
clc;
close all;
warning off Images:initSize:adjustingMag % suppress the warning about big images, they are still displayed correctly, just a bit smaller..
tic;

%% run/file parameters
consecutiveTif = 0;      % write Tifs as #1..2..3 instead of as #FromToTo

% which sample?
SampleBaseName = 'R243b10_';

%% setup
UserID = 'e11126';
BasePath = [ '/sls/X02DA/data/' UserID '/Data10/2008b/' ];

ReadPath  = [ BasePath 'mrg/' SampleBaseName 'mrg/DMP/' ];
WritePath = [ BasePath 'mrg/' SampleBaseName 'mrg/tif/' ];

LogFileFullPath=fullfile(WritePath, [ SampleBaseName 'mrg.log' ]);

[LogFilePath, LogFileName, LogFileExtenstion,FileVersion] = fileparts(LogFileFullPath);
[success,message,messageID] = mkdir(LogFilePath);

%count DMPs
cd([ ReadPath ]);
filelist = dir([fileparts(ReadPath) filesep '*.DMP']);
NumDMP = length({filelist.name});
disp(['We`ve got ' num2str(NumDMP) ' merged Projections as DMPs in ' ReadPath ]);

%TMP
NumDMP = 14:32:NumDMP;
disp('---')
disp('---')
disp(['Until all DMPs are ready, were only using the first ' num2str(length(NumDMP)) ' to proceed' ]);
disp('---')
disp('---')
%TMP

% for n = 1:75
%     which = round(rand*length(NumDMP));
%     DMPNr = NumDMP(which);
%     disp(['Reading DMP #' num2str(sprintf('%04d',DMPNr)) ' for the calculation of GlobalMin and GlobalMax' ]);
%     DMPFileName = [ ReadPath SampleBaseName 'mrg-' num2str(sprintf('%04d',DMPNr)) '.DMP' ];
%     DMP = readDumpImage(DMPFileName);
%     GlobalMin(n) = min(min(DMP));
%     GlobalMax(n) = max(max(DMP));
%     clear DMP;
% end
GlobalMin = -1; %min(GlobalMin)
GlobalMax = 2; %max(GlobalMax)

% CONSECUTIVE NUMBERING!
for which = 1:length(NumDMP)
    DMPNr = NumDMP(which);
    disp(['Reading DMP #' num2str(sprintf('%04d',DMPNr)) ' & writing it to tiff in ' WritePath ]);
    DMPFileName = [ ReadPath SampleBaseName 'mrg-' num2str(sprintf('%04d',DMPNr)) '.DMP' ];
    DMP = readDumpImage(DMPFileName);
    DMP = DMP -  GlobalMin;
    DMP = DMP ./ GlobalMax;
    WriteTifName = [ LogFilePath '/' SampleBaseName num2str(sprintf('%04d',DMPNr)) ];
    imwrite(DMP,[WriteTifName '.tif'],'Compression','none');  % Compression none, so that ImageJ can read the tiff-files...
%     figure
%         imshow(DMP,[])
%     pause(.5)
%     close
    clear DMP;
end

%%%%%%%%%%%%%%%%%
% generate fake LogFile
%%%%%%%%%%%%%%%%%

NumDarks = 0;
NumFlats = 0;
Magnification = 10;


disp(['Im counting the filenumber of the tiffs in ' WritePath '...']);

cd(WritePath);
filelist = dir([fileparts(WritePath) filesep '*.tif']);
NumTiff = length({filelist.name});
disp(['We`ve got ' num2str(NumTiff) ' Tiffs in ' WritePath ]);


%% write the stuff to a faked log-file.    
    % User ID : e11126
dlmwrite(LogFileFullPath, ['User ID : ' UserID],'delimiter','');
% FAST-TOMO scan of sample R108C60c_s1 started on Mon Oct 06 18:51:01 2008 
dlmwrite(LogFileFullPath, ['FAST-TOMO scan of sample ' SampleBaseName 'mrg. Log was faked on ' datestr(now) ],'-append','delimiter','');
% % --------------------Beamline Settings-------------------------
dlmwrite(LogFileFullPath, ['--------------------Beamline Settings-------------------------'],'-append','delimiter','');
% % Ring current [mA]           : 400.650 
dlmwrite(LogFileFullPath, ['Ring current [mA]           : XXX.XXX'],'-append','delimiter','');
% Beam energy  [keV]          : 15.072 
dlmwrite(LogFileFullPath, ['Beam energy  [keV]          : XXX.XXX'],'-append','delimiter','');
% Monostripe                  : Ru/C 
dlmwrite(LogFileFullPath, ['Monostripe                  : Ru/C'],'-append','delimiter','');
% --------------------Detector Settings-------------------------
dlmwrite(LogFileFullPath, ['--------------------Detector Settings-------------------------'],'-append','delimiter','');
% Objective                   : 10.00 
dlmwrite(LogFileFullPath, ['Objective                   : ' num2str(sprintf('%.2f',Magnification)) ],'-append','delimiter','');
% Scintillator                : YAG:Ce 18 um 
dlmwrite(LogFileFullPath, ['Scintillator                : YAG:Ce 18 um'],'-append','delimiter','');
% Exposure time [ms]          : 500 
dlmwrite(LogFileFullPath, ['Exposure time [ms]          : XXX'],'-append','delimiter','');
% ------------------------Scan Settings-------------------------
dlmwrite(LogFileFullPath, ['------------------------Scan Settings-------------------------'],'-append','delimiter','');
% Sample folder                : /sls/X02DA/data/e11126/Data10/2008b/R108C60c_s1 
dlmwrite(LogFileFullPath, ['Sample folder                : ' WritePath ],'-append','delimiter','');
% File Prefix                  : R108C60c_s1 
dlmwrite(LogFileFullPath, ['File Prefix                  : ' SampleBaseName 'mrg' ],'-append','delimiter','');
% Number of projections        : 4676 
dlmwrite(LogFileFullPath, ['Number of projections        : ' num2str(NumTiff) ],'-append','delimiter','');
% Number of darks              : 2 
dlmwrite(LogFileFullPath, ['Number of darks              : ' num2str(NumDarks) ],'-append','delimiter','');
% Number of flats              : 10 
dlmwrite(LogFileFullPath, ['Number of flats              : ' num2str(NumFlats) ],'-append','delimiter','');
% Number of inter-flats        : 0 
dlmwrite(LogFileFullPath, ['Number of inter-flats        : 0'],'-append','delimiter','');
% Inner scan flag              : 0 
dlmwrite(LogFileFullPath, ['Inner scan flag              : 0'],'-append','delimiter','');
% Flat frequency               : 0 
dlmwrite(LogFileFullPath, ['Flat frequency               : 0'],'-append','delimiter','');
% Rot Y min position  [deg]    : 45.000 
dlmwrite(LogFileFullPath, ['Rot Y min position  [deg]    : 45.000'],'-append','delimiter','');
% Rot Y max position  [deg]    : 225.000 
dlmwrite(LogFileFullPath, ['Rot Y max position  [deg]    : 225.000'],'-append','delimiter','');
% Angular step [deg]           : 0.039 
dlmwrite(LogFileFullPath, ['Angular step [deg]           : 0.039'],'-append','delimiter','');
% Sample In   [um]             : -1442 
dlmwrite(LogFileFullPath, ['Sample In   [um]             : 0'],'-append','delimiter','');
% Sample Out  [um]             : 10000 
dlmwrite(LogFileFullPath, ['Sample Out  [um]             : 10000'],'-append','delimiter','');
% --------------------------------------------------------------
dlmwrite(LogFileFullPath, ['--------------------------------------------------------------'],'-append','delimiter','');
% Start logging activity...
dlmwrite(LogFileFullPath, ['Start logging activity...'],'-append','delimiter','');% Start logging activity...
dlmwrite(LogFileFullPath, ['It`s a fake log-file, believe me!'],'-append','delimiter','');
dlmwrite(LogFileFullPath, ['But the stuff below might be of value again...'],'-append','delimiter','');
 
% %%%%%%%%%%%%%%%%%
% % finish
% %%%%%%%%%%%%%%%%%

disp('I`m done with all you`ve asked for...')
disp(['It`s now ' datestr(now) ]);
zyt=toc;
disp(['It took me approx. ' num2str(round(zyt/60)) ' minutes to perform the given task' ]);
%helpdlg('I`m done with all you`ve asked for...','Phew!');