clc;clear all;close all;

BeamTime = '2009c';
SampleName = 'R244-D01_t';
AmoutOfSubScans = 3;
NumDarks = 5;
NumFlats = 20;

Tiff = 1; % Tiff = 0 > write to disk as DMPs

disp('Starting to merge');

% OutputSampleName = 'R244-d01_t';
% OutputSuffix = 'nrm'; % R244-d01_t_s1.._s3
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
%---
% OutputSampleName = 'R244-d01_t';
% OutputSuffix = 'sns'; % R244-d01_tss_s1.._s3
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
%---
% OutputSampleName = 'R244-d01';
% OutputSuffix = 't'; % R244-d01_ts_s1.._s3
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
%---
%OutputSampleName = 'R244-d01';
%OutputSuffix = 'b'; % R244-d01_bs_s1.._s3
%fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
%close all;
%---
OutputSampleName = 'R244-d30';
OutputSuffix = 't'; % R244-d30_t_s1.._s3
fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
close all;
% %---
% OutputSampleName = 'R108C60_b';
% OutputSuffix = 'A'; % R108C60B_b_s1.._s3
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% %---
% OutputSampleName = 'R108C60_t';
% OutputSuffix = 'A'; % R108C60B_t_s1.._s3
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% %---
% OutputSampleName = 'R108C60_t';
% OutputSuffix = 'B'; % R108C60B_t_s4.._s6
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% %---
% OutputSampleName = 'R108C60_t';
% OutputSuffix = 'C'; % R108C60B_t_s7.._s9
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% %---
% OutputSampleName = 'R108C60_t';
% OutputSuffix = 'D'; % R108C60B_t_s10.._s12
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% %---
% OutputSampleName = 'R108C60_t';
% OutputSuffix = 'E'; % R108C60B_t_s13.._s15
% fct_mergeSubScanSelector(AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% close all;
% %---

disp('-----');
disp('Done with everything!');
disp('-----');
