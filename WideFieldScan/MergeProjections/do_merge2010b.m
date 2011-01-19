clc;clear all;close all;

BeamTime = '2010b';
AmoutOfSubScans = 3;
NumDarks = 10;
NumFlats = 50;

Tiff = 1; % Tiff = 0 > write to disk as DMPs

disp('Starting to merge');

%OutputSampleName = 'R108C10C_';
%OutputSuffix = 'B1'; % R108C10_B1_s1..._s3
%fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
%--
%OutputSuffix = 'B2'; % R108C10_B2_s1..._s3
%fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;

%OutputSampleName = 'R108C36A_';
%OutputSuffix = 'B1'; % R108C36A_B1_s1..._s3
%fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
%--
%OutputSuffix = 'B2'; % R108C36A_B2_s1..._s3
%fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
%--
%OutputSuffix = 'B3'; % R108C36A_B3_s1..._s3
%fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;

%OutputSampleName = 'R108C04Aa_';
%OutputSuffix = 'B1'; % R108C04Aa_s1..._s3
%fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
%--
%OutputSuffix = 'B2'; % R108C04Aa_s1..._s3
%fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;

OutputSampleName = 'R108C60B_';
OutputSuffix = 'B1'; % R108C60B_s1..._s3
fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
close all;
%--
OutputSuffix = 'B2'; % R108C60B_s1..._s3
fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
close all;
%--
%OutputSuffix = 'B3'; % R108C60B_s1..._s3
%fct_mergeSubScansInterpolatedSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;



