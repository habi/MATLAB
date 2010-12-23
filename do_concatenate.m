%% concatenate
%% concatenates input-images while calculating the correct cut-line with
%% Xris' methos

%% 2008-08-26 initial version

%% Clear Workspace
clear;
clc;
close all;


%% setup parameters
Path = '/sls/X02DA/Data10/e11126/2008a/';
SampleBaseName = 'R108C04BrulW_';
leftestName = 's1';
leftName = 's2';
centerName = 's3';
rightName = 's4';
rightestName = 's5';
InputDirectory = 'tif';
OutputDirectory = 'cnc';
NumDarks = 5;
NumFlats = 5;
TotalCenterProj = 1524;
TotalFileNumber = NumDarks + NumFlats + 4*TotalCenterProj + NumFlats;
for FileNumber = 4700:TotalFileNumber - NumFlats%1 + NumDarks + NumFlats:TotalFileNumber - NumFlats;
    w = waitbar(FileNumber/TotalFileNumber,['concatenating image ' num2str(FileNumber) ' of ' num2str(TotalFileNumber)]);
    %% generally, there is no need to change anything below this line...
    CenterFileNumber = sprintf('%04d',round(FileNumber/4)+NumDarks+NumFlats-2)
    FileNumber = sprintf('%04d',FileNumber)
    warning off Images:initSize:adjustingMag % suppress the warning about big images, they are still displayed correctly, just a bit smaller..

    %% load images
    fullloadpath = [Path SampleBaseName leftName   '/' InputDirectory '/' SampleBaseName leftName ];

    DarkImage = double(imread([Path SampleBaseName centerName   '/' InputDirectory '/' SampleBaseName centerName '0001.tif']));
    FlatImage = double(imread([Path SampleBaseName centerName   '/' InputDirectory '/' SampleBaseName centerName '0006.tif']));
%     figure
%         subplot(121)
%         imshow(DarkImage,[])
%         title('dark image')
%         subplot(122)
%         imshow(FlatImage,[])
%         title('flat image')
    LeftestImage   = double(imread([Path SampleBaseName leftestName   '/' InputDirectory '/' SampleBaseName leftestName FileNumber '.tif']));    
    LeftImage   = double(imread([Path SampleBaseName leftName   '/' InputDirectory '/' SampleBaseName leftName FileNumber '.tif']));
    CenterImage = double(imread([Path SampleBaseName centerName '/' InputDirectory '/' SampleBaseName centerName CenterFileNumber '.tif']));
    RightImage  = double(imread([Path SampleBaseName rightName  '/' InputDirectory '/' SampleBaseName rightName FileNumber '.tif']));
    RightestImage  = double(imread([Path SampleBaseName rightestName  '/' InputDirectory '/' SampleBaseName rightestName FileNumber '.tif']));
    %% normalize images
    LeftImage = LeftImage - DarkImage;
    LeftImage = LeftImage - DarkImage;
    CenterImage = CenterImage - DarkImage;
    RightImage = RightImage - DarkImage;
    RightestImage = RightestImage - DarkImage;

    %% correct images
    LeftestImage = log(FlatImage) - log(LeftestImage);
    LeftImage = log(FlatImage) - log(LeftImage);
    CenterImage = log(FlatImage) - log(CenterImage);
    RightImage = log(FlatImage) - log(RightImage);
    RightestImage = log(FlatImage) - log(RightestImage);

    %% concatenate images
    ConcatenatedImage = [LeftestImage LeftImage CenterImage RightImage RightestImage];
%     figure
%         imshow(ConcatenatedImage,[])
%         title('just stitched')

    %% compute overlap
    %% here should be the overlap-calculation of chris.
    %% for the moment we're just setting the overlap manually to the 15%
    %% we've set in widefieldscan.m before scanning.
    overlap = 0.15;
    CutLeftestImage = LeftestImage(:,1:round(size(LeftestImage,2)*(1-overlap))-1);
    CutLeftImage = LeftImage(:,1:round(size(LeftImage,2)*(1-overlap))-1);
    CutRightImage = RightImage(:,size(RightImage,2)-round((size(RightImage,2)*(1-overlap)))+1:size(RightImage,2));
    CutRightestImage = RightestImage(:,size(RightestImage,2)-round((size(RightestImage,2)*(1-overlap)))+1:size(RightestImage,2));

    CutConcatenatedImage = [CutLeftestImage CutLeftImage CenterImage CutRightImage CutRightestImage];
    CutConcatenatedImage = CutConcatenatedImage - min(min(CutConcatenatedImage));
    CutConcatenatedImage = CutConcatenatedImage ./ max(max(CutConcatenatedImage));

%     figure
%         imshow(CutConcatenatedImage,[0:1])
%         title('concatenated correctly');

    %% write file
    imwrite(CutConcatenatedImage,[Path SampleBaseName OutputDirectory '/' SampleBaseName OutputDirectory FileNumber '.tif'],'Compression','none')
    
    close(w)
end
disp('done!');