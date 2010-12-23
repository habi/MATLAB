%% widefieldscan
%% gives the user the possibility to choose the quality (from
%% input-constraints) and outputs parameters for the scan

%% 2008-08-08 initial version
%% 2008-08-15 added working output

%% Clear Workspace
clear;
clc;
close all;
writeout = 0;

% reply = input('Do you want more? Y/N [Y]: ', 's');
% if isempty(reply)
%     reply = 'Y';
% end

%% ask the user some questions
disp('I will ask you some questions so that I can calculate the scan parameters');

%Open prompt as cell array (from: http://tinyurl.com/6awr65
prompt={'Please input the Field of View you would like to achieve (in mm!) [4mm]:',...
    'Detector Width'};
 
FOV_um = input(['Please input the Field of View you would like to achieve (in mm!) [4mm]: ']) * 1000;
if isempty(FOV_um)
    FOV_um = 4000;
end

DetectorWidth_px = input(['Please input the Detector witdh in pixels [1024px]: ']);
if isempty(DetectorWidth_px)
    DetectorWidth_px = 1024;
end

pixelsize = 0;
while isempty(pixelsize) || ( pixelsize < 0.3 )
    disp('Please input the Magnification-Factor [default = 0 = 10x]');
    disp('If you input NOTHING for the Magnification I`ll ');
    Magnification = input(['ask you for the calibration parameters [10x]: ']);
    if isempty(Magnification)
        disp('You seem to want to perform a calibration');
        disp('Please use the preview window of the camera:');
        CalibrationPositionA = input('go as far left as possible, make a snapshot, insert the pixel value');
        CalibrationPositionB = input('go as far right as possible, make a snapshot, insert the pixel value');
        CalibrationDistance_um = input('please insert the calibration distance in MICROMETER');
        pixelsize = abs(CalibrationPositionB - CalibrationPositionA)/ CalibrationDistance_um;
    elseif Magnification == 0
        pixelsize = 0.74;
    else
        pixelsize = 7.4/Magnification;
    end
end

Binning = input(['Please input the Binning-Factor [2]: ']);
if isempty(Binning)
    pixelsize = pixelsize * 2;
    Binning = 2;
else
    pizelsize = pixelsize * Binning;
end

%Overlap_percent = 100;
%while Overlap_percent > 25
    disp('Please input the Overlap that you`d like to have');
    %Overlap_percent = input('between your projection images (in percent ranging from 5 to 25% overlap!) [15%]: ');
    Overlap_px = input('between your projection images (in pixels!) [150]: ');
    if isempty(Overlap_px)
%         Overlap_percent = 15;
        Overlap_px = 150 ;%DetectorWidth_px * Overlap_percent / 100;
%     else
%          Overlap_px = DetectorWidth_px * Overlap_percent / 100;
    end
%end

disp('---');
disp('The questions below are mainly for informal purposes...');
disp('---');

ExposureTime = input(['Please input the expected Exposuretime [100] milisec: ']);
if isempty(ExposureTime)
    ExposureTime = 100 / 1000;
else
    ExposureTime = ExposureTime / 1000;
end

AmountOfDarks = input(['Please input the Amount of Dark images [5]: ']);
if isempty(AmountOfDarks)
    AmountOfDarks = 5;
end

AmountOfFlats = input(['Please input the Amount of Flat images [5]: ']);
if isempty(AmountOfFlats)
    AmountOfFlats = 10;
else
    AmountOfFlats = AmountOfFlats *2;
end

SegmentQuality = 60; % lowest acceptable quality we want to have

% crunching numbers

% do we need rings?
ImageSegmentWidth_px = DetectorWidth_px - Overlap_px;
SegmentNumber=ceil( FOV_um / pixelsize / ImageSegmentWidth_px);
disp(['We need ' num2str(SegmentNumber) ' Segments to cover your chosen FOV']);

if SegmentNumber == 2
    disp('i propose one simple 360-scan')
    InbeamPosition_um = [ ImageSegmentWidth_px / 2 , - ImageSegmentWidth_px / 2 ] .* pixelsize
    RotationStartAngle = [  0,   0]
    RotationStopAngle  = [360, 360]
    break
elseif ~mod(SegmentNumber,2) % tilde inverts the condition
    SegmentNumber = SegmentNumber + 1;
    disp(['Since we need an odd number, we thus scan with ' num2str(SegmentNumber) ' Segments...']);
end

TotalWidth_px = SegmentNumber * ImageSegmentWidth_px;
GlobalSegmentNumber = SegmentNumber;
GlobalTotalWidth_px = TotalWidth_px;
GlobalNumberOfProjections = [];

for InitialQuality = 60:10:100
    SegmentNumber = GlobalSegmentNumber;
    TotalWidth_px = GlobalTotalWidth_px;
    while SegmentNumber > 0       
        NumberOfProjections = h_reducesegments(GlobalTotalWidth_px,TotalWidth_px,ImageSegmentWidth_px,SegmentNumber,InitialQuality/100,SegmentQuality/100);
        SegmentNumber;
        TotalWidth_px = TotalWidth_px- 2 * ImageSegmentWidth_px;
        SegmentsToAdd = floor((GlobalSegmentNumber - SegmentNumber )/ 2);
        if SegmentsToAdd > 0
            tmpvector = ones(size(NumberOfProjections,1),SegmentsToAdd) .* GlobalTotalWidth_px .* InitialQuality/100;
            NumberOfProjections = [ tmpvector NumberOfProjections tmpvector ];
        end
        SegmentNumber = SegmentNumber - 2;
        if ~isempty(GlobalNumberOfProjections)
            if size(GlobalNumberOfProjections,1) > 1
                GlobalNumberOfProjections = GlobalNumberOfProjections(2:size(GlobalNumberOfProjections,1),:);
            else
                GlobalNumberOfProjections = [];
            end
        end
        GlobalNumberOfProjections = [ NumberOfProjections; GlobalNumberOfProjections ];
    end
end

GlobalNumberOfProjections = flipud(unique(GlobalNumberOfProjections,'rows','first'))
rowsum = sum(GlobalNumberOfProjections,2);
quality = rowsum ./ rowsum(1) .* 100;

[sortedquality permutation] = sort(quality,'descend');
GlobalNumberOfProjections = GlobalNumberOfProjections(permutation,:);
rowsum = ( rowsum(permutation,:) + ( AmountOfDarks + AmountOfFlats) * size(GlobalNumberOfProjections,2) ) .* ExposureTime / 60;
GlobalTimeforScans = ( GlobalNumberOfProjections + AmountOfDarks + AmountOfFlats ) .* ExposureTime / 60;

figure
    plot(sortedquality,rowsum,'-s')
    ylabel('estimated ScanTime [min]')
    xlabel('estimated ScanQuality [%]')
    
%% choose which protocol
h=helpdlg('Choose 1 square from the quality-plot (quality vs. total scan-time!). One square corresponds to one possible protocol. Take a good look at the time on the left and the quality on the bottom. I`ll then calculate the protocol that best fits your choice','Protocol Selection'); 
uiwait(h);
[userx,usery] = ginput(1);
[mindiff minidx ] = min(abs(sortedquality - userx));
User_NumProj = GlobalNumberOfProjections(minidx,:);

if writeout == 1
    %% choose the path
    h=helpdlg('Now please choose a path where I should write the output-file'); 
    close;
    uiwait(h);
    %User_Path = uigetdir;
    %pause(0.5);
    disp('USING HARDCODED USER_PATH SINCE X-SERVER DOESNT OPEN uigetdir!!!');
    User_Path = '/sls/X02DA/Data10/e11126/2008b'
    %% input samplename
    User_SampleName = input('Now please input a SampleName: ', 's');
end

%% output the NumProj the user wants into Matrix
[mindiff minidx ] = min(abs(sortedquality - userx));
ScanWhichTheUserWants = GlobalNumberOfProjections(minidx,:)';
h=helpdlg(['I`ve chosen protocol ' num2str(minidx) ' corresponding to ' num2str(size(GlobalNumberOfProjections,2)) ...
    ' scans with NumProj like this: ' num2str(ScanWhichTheUserWants') ' as a best match to your selection.']);
uiwait(h);
% write NumProj to first column of output
OutputMatrix(:,1)=ceil(ScanWhichTheUserWants);

%% calculate InbeamPosition
ImageSegmentWidth_um = ImageSegmentWidth_px * pixelsize;
User_InbeamPosition=ones(size(ScanWhichTheUserWants,1),1);
for position = 1:length(User_InbeamPosition)
    User_InbeamPosition(position) = ImageSegmentWidth_um * position - (ceil(length(User_InbeamPosition)/2)*ImageSegmentWidth_um);
end
% write InbeamPositions to second column of output
OutputMatrix(:,2)=User_InbeamPosition;

%% set angles
RotationStartAngle = 45;
RotationStopAngle  = 225;
% write angles to second column of output
OutputMatrix(:,3)=RotationStartAngle;
OutputMatrix(:,4)=RotationStopAngle;

if writeout == 1
    %% write Header to textfile
    dlmwrite([User_Path '/' User_SampleName '.txt' ], ['# Path = ' User_Path],'delimiter','');
    dlmwrite([User_Path '/' User_SampleName '.txt' ], ['# SampleName = ' User_SampleName],'-append','delimiter','');
    dlmwrite([User_Path '/' User_SampleName '.txt' ], ['# FOV = ' num2str(FOV_um) 'um'],'-append','delimiter','');
    dlmwrite([User_Path '/' User_SampleName '.txt' ], ['# DetectorWidth = ' num2str(DetectorWidth_px) 'px'],'-append','delimiter','');
    dlmwrite([User_Path '/' User_SampleName '.txt' ], ['# Magnification = ' num2str(Magnification) 'x'],'-append','delimiter','');
    dlmwrite([User_Path '/' User_SampleName '.txt' ], ['# Binning = ' num2str(Binning) ' x ' num2str(Binning)],'-append','delimiter','');
    dlmwrite([User_Path '/' User_SampleName '.txt' ], ['# Overlap = ' num2str(Overlap_px) ' px'],'-append','delimiter','');
    dlmwrite([User_Path '/' User_SampleName '.txt' ], '#---','-append','delimiter','');
    dlmwrite([User_Path '/' User_SampleName '.txt' ], '# NumProj InBeamPosition StartAngle StopAngle','-append','delimiter','');
    % dlmwrite([User_Path '/' User_SampleName '.txt' ], '#---','-append','delimiter','');

    %% write final output matrix to text file
    dlmwrite([User_Path '/' User_SampleName '.txt' ], OutputMatrix,  '-append', 'roffset', 1, 'delimiter', ' ');
end