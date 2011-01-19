clc;clear all;close all;

AmoutOfSubScans = 3;
NumDarks = 5;
NumFlats = 20;

Tiff = 1; % Tiff = 0 > write to disk as DMPs

disp('Starting to merge');

OutputSampleName = 'R108C21C';
%%%%
% OutputSuffix = 'b';
% fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% %%%%
% OutputSuffix = 'd';
% fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
%%%%
% OutputSuffix = 'm';
% fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% %%%%
% OutputSuffix = 'n';
% fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% %%%%
OutputSuffix = 's';
fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
close all;
%%%%
OutputSuffix = 't';
fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
close all;
%%%%

disp('-----');
disp('Done with everything!');
disp('-----');
