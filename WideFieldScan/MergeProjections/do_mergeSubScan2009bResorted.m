clc;clear all;close all;

SampleName = 'R108C36B';
AmoutOfSubScans = 3;
NumDarks = 1;
NumFlats = 1;

Tiff = 1; % Tiff = 0 > write to disk as DMPs

OutputSampleName = 'Test23';
disp('Starting to merge');

%OutputSuffix = 'Aa'; % 1,2div2,3
%fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
%OutputSuffix = 'Ab'; % 1,2div4,3
%fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
%OutputSuffix = 'Ac'; % 1,2div8,3
%fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
% %%%%%%%%%%%%
%OutputSuffix = 'Ba'; % 4,5div2,6
%fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
%OutputSuffix = 'Bb'; % 4,5div4,6
%fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
%OutputSuffix = 'Bc'; % 4,5div8,6
%fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
% %%%%%%%%%%%%
%OutputSuffix = 'Ca'; % 7,8div2,9
%fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
% %%%%%%%%%%%%
%OutputSuffix = 'Cb'; % 7,8div4,9
%fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
OutputSuffix = 'Cc'; % 7,8div8,9
fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
close all;
% %%%%%%%%%%%%
% OutputSuffix = 'Da'; % 10,11div2,12
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% OutputSuffix = 'Db'; % 10,11div4,12
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% OutputSuffix = 'Dc'; % 10,11div8,12
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;

disp('-----');
disp('Done with everything!');
disp('-----');
