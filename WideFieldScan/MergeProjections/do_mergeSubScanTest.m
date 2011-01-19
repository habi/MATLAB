clc;clear all;close all;

SampleName = 'R108C36C';
AmoutOfSubScans = 3;
NumDarks = 5;
NumFlats = 20;

Tiff = 1; % Tiff = 0 > write to disk as DMPs

OutputSampleName = 'TestTest';
disp('Starting to merge');

% OutputSuffix = 'A';
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% 
% OutputSuffix = 'B';
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% 
% OutputSuffix = 'C';
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;

OutputSuffix = 'D';
fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
close all;

disp('-----');
disp('Done with everything!');
disp('-----');
