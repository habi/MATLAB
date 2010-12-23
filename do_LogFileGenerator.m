clc
clear
close all

UserID = 'e11126';
basepath = [ '/sls/X02DA/data/' UserID '/Data10/2008b/' ];
samplename = 'R243b10_';

Magnification = 10;
%NumProj is counted below
NumDarks = 0;
NumFlats = 0;
inputDirsuffix = 's1';
outputDirsuffix = 'mrg';
readDir = '/tif/';
writeDir = '';
filesuffix = '.log';

ReadSampleName = [ samplename inputDirsuffix]
inputfile = [ basepath ReadSampleName readDir ReadSampleName filesuffix ]

WriteSampleName = [ samplename outputDirsuffix]
outputpath = [ basepath 'mrg/' WriteSampleName  ]
[success,message,messageID] = mkdir([outputpath '/tif/' ]);
outputfile = [ outputpath '/tif/' WriteSampleName filesuffix ]

disp(['Im counting the filenumber of the tiffs in the /mrg-Directory of ' WriteSampleName '...']);

cd([outputpath '/tif/']);
filelist = dir([fileparts([outputpath '/tif/']) filesep '*.tif']);
NumProj = length({filelist.name});
disp(['We`ve got ' num2str(NumProj) ' merged Projections.']);
    
%% write the stuff to a faked log-file.    
% User ID : e11126
dlmwrite(outputfile, ['User ID : ' UserID],'delimiter','');
% FAST-TOMO scan of sample R108C60c_s1 started on Mon Oct 06 18:51:01 2008 
dlmwrite(outputfile, ['FAST-TOMO scan of sample ' WriteSampleName '. Log was faked on ' datestr(now) ],'-append','delimiter','');
% --------------------Beamline Settings-------------------------
dlmwrite(outputfile, ['--------------------Beamline Settings-------------------------'],'-append','delimiter','');
% Ring current [mA]           : 400.650 
dlmwrite(outputfile, ['Ring current [mA]           : 400.650'],'-append','delimiter','');
% Beam energy  [keV]          : 15.072 
dlmwrite(outputfile, ['Beam energy  [keV]          : 15.072'],'-append','delimiter','');
% Monostripe                  : Ru/C 
dlmwrite(outputfile, ['Monostripe                  : Ru/C'],'-append','delimiter','');
% --------------------Detector Settings-------------------------
dlmwrite(outputfile, ['--------------------Detector Settings-------------------------'],'-append','delimiter','');
% Objective                   : 10.00 
dlmwrite(outputfile, ['Objective                   : ' num2str(sprintf('%.2f',Magnification)) ],'-append','delimiter','');
% Scintillator                : YAG:Ce 18 um 
dlmwrite(outputfile, ['Scintillator                : YAG:Ce 18 um'],'-append','delimiter','');
% Exposure time [ms]          : 500 
dlmwrite(outputfile, ['Exposure time [ms]          : 500'],'-append','delimiter','');
% ------------------------Scan Settings-------------------------
dlmwrite(outputfile, ['------------------------Scan Settings-------------------------'],'-append','delimiter','');
% Sample folder                : /sls/X02DA/data/e11126/Data10/2008b/R108C60c_s1 
dlmwrite(outputfile, ['Sample folder                : ' outputpath ],'-append','delimiter','');
% File Prefix                  : R108C60c_s1 
dlmwrite(outputfile, ['File Prefix                  : ' WriteSampleName ],'-append','delimiter','');
% Number of projections        : 4676 
dlmwrite(outputfile, ['Number of projections        : ' num2str(NumProj) ],'-append','delimiter','');
% Number of darks              : 2 
dlmwrite(outputfile, ['Number of darks              : ' num2str(NumDarks) ],'-append','delimiter','');
% Number of flats              : 10 
dlmwrite(outputfile, ['Number of flats              : ' num2str(NumFlats) ],'-append','delimiter','');
% Number of inter-flats        : 0 
dlmwrite(outputfile, ['Number of inter-flats        : 0'],'-append','delimiter','');
% Inner scan flag              : 0 
dlmwrite(outputfile, ['Inner scan flag              : 0'],'-append','delimiter','');
% Flat frequency               : 0 
dlmwrite(outputfile, ['Flat frequency               : 0'],'-append','delimiter','');
% Rot Y min position  [deg]    : 45.000 
dlmwrite(outputfile, ['Rot Y min position  [deg]    : 45.000'],'-append','delimiter','');
% Rot Y max position  [deg]    : 225.000 
dlmwrite(outputfile, ['Rot Y max position  [deg]    : 225.000'],'-append','delimiter','');
% Angular step [deg]           : 0.039 
dlmwrite(outputfile, ['Angular step [deg]           : 0.039'],'-append','delimiter','');
% Sample In   [um]             : -1442 
dlmwrite(outputfile, ['Sample In   [um]             : -1442'],'-append','delimiter','');
% Sample Out  [um]             : 10000 
dlmwrite(outputfile, ['Sample Out  [um]             : 10000'],'-append','delimiter','');
% --------------------------------------------------------------
dlmwrite(outputfile, ['--------------------------------------------------------------'],'-append','delimiter','');
% Start logging activity...
dlmwrite(outputfile, ['Start logging activity...'],'-append','delimiter','');% Start logging activity...
dlmwrite(outputfile, ['It`s a fake log-file, believe me!'],'-append','delimiter','');
dlmwrite(outputfile, ['But the stuff below might be of value again...'],'-append','delimiter','');