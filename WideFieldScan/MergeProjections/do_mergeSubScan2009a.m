clc;clear all;close all;

SampleName = 'R108C36C';
AmoutOfSubScans = 3;
NumDarks = 10;
NumFlats = 10;

Tiff = 1; % Tiff = 0 > write to disk as DMPs

Suffixes = [ 'a';'b';'c';'d';'e';'f';'g';'h';'i';'j';'k';'l';'m';'n';'o';'p';'q';'r';'s';'t';'u';'v';'w';'x';'y';'z'];

% SampleName = 'R108C36C';
% for WorkOnScan = 1:4
%     FirstSubScan = 3 * WorkOnScan - 2;
%     OutputSampleName = 'R108C36C';
%     OutputSuffix = Suffixes(WorkOnScan);
%     disp('Starting to merge');
%     fct_mergeSubScan(SampleName,FirstSubScan,AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
% end

SampleName = 'R108C36C3';
for WorkOnScan = 2:4
    FirstSubScan = 3 * WorkOnScan - 2;
    OutputSampleName = 'R108C36C';
    OutputSuffix = Suffixes(4+WorkOnScan);
    disp('Starting to merge');
    fct_mergeSubScan(SampleName,FirstSubScan,AmoutOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)
end

disp('-----');
disp('Done with everything!');
disp('-----');