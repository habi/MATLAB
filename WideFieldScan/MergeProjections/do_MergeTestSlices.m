clc;clear all;close all;

AmoutOfSubScans = 3;
NumDarks = 0;
NumFlats = 0;

Tiff = 1; % Tiff = 0 > write to disk as DMPs

disp('Starting to merge');

OutputSampleName = 'Test';
OutputSuffix = '04';
fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
close all;
%%%%%%%%%%%%%%%
OutputSampleName = 'Test';
OutputSuffix = '08';
fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
close all;
%%%%%%%%%%%%%%%
OutputSampleName = 'Test';
OutputSuffix = '16';
fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
close all;
%%%%%%%%%%%%%%%
OutputSampleName = 'Test';
OutputSuffix = '32';
fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
close all;

disp('-----');
disp('Done with everything!');
disp('-----');
