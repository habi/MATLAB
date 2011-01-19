clc;clear all;close all;

%% Setup
Drive = 'R';
BeamTime = '2010b';
Sample = 'R108C04Aa';
Stack = 1;
SubScan = 1;
ReadLinesOfLogFile = 33;

%% Generate Name
SampleName = [ Sample '_B' num2str(Stack) '_s' num2str(SubScan) '_' ];
LogFileLocation = [ Drive ':' filesep 'SLS' filesep BeamTime filesep ...
	'log' filesep SampleName '.log' ];
disp([ 'Reading LogFile ' LogFileLocation ' to extract all relevant Data.']);
disp('---');
%% Read Logfile for parsing the needed Data
% (from http://is.gd/cAYfT)
fid = fopen(LogFileLocation,'r'); % Open text file
LogFile = textscan(fid,'%s',ReadLinesOfLogFile,'delimiter','\n');
LogFile = LogFile{1};
% split LogFile at ':' so we can extract the values
TMP = regexp(LogFile, ':', 'split');
% get Values and strip leading and trailing spaces
UserID = strtrim(TMP{1}{2})
RingCurrent = strtrim(TMP{4}{2})
BeamEnergy = strtrim(TMP{5}{2})
Mono = strtrim(TMP{6}{2})
Objective = strtrim(TMP{8}{2})
Scintillator = strtrim(TMP{9}{2})
ExposureTime = strtrim(TMP{10}{2})
SampleFolder = strtrim(TMP{12}{2})
Projections = strtrim(TMP{14}{2})
Darks = strtrim(TMP{15}{2})
Flats = strtrim(TMP{16}{2})
 
 
 
 
disp('---');