clc;clear all;close all;

BeamTime = '2009f';
SampleName = 'R108C60E';
AmoutOfSubScans = 3;
NumDarks = 5;
NumFlats = 30;

Tiff = 1; % Tiff = 0 > write to disk as DMPs

disp('Starting to merge');

% OutputSampleName = 'R108C60E';
% OutputSuffix = 't'; % R108C60Et_s1.._s3
% fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% %---
% OutputSuffix = 'm'; % R108C60Em_s1.._s3
% fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% %---
% OutputSuffix = 'b'; % R108C60Eb_s1.._s3
% fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;


%---
%OutputSampleName = 'R108C36E';
%OutputSuffix = 't'; % R108C36Et_s1.._s3
%fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
%---
%OutputSuffix = 'm'; % R108C36Em_s1.._s3
%fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
%---
%OutputSuffix = 'b'; % R108C36Eb_s1.._s3
%fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
% %---


OutputSampleName = 'R108C60D';
% OutputSuffix = 't'; % R108C60Dt_s1.._s3
% fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
%---
OutputSuffix = 'm'; % R108C60Dm_s1.._s3
fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
close all;
% %---
% OutputSuffix = 'b'; % R108C60Db_s1.._s3
% fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% % %---


%OutputSampleName = 'R108C21A2';
%OutputSuffix = 't'; % R108C21A2b_s1.._s3
%fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
%---
%OutputSuffix = 'm'; % R108C21A2T_s1.._S3
%fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
%---


disp('-----');
disp('Done with everything!');
disp('-----');
