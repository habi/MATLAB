%% widefieldscan
%% gives the user the possibility to choose the quality (from
%% input-constraints) and outputs parameters for the scan

%% 2008-08-08 initial version

%% Clear Workspace
clear;
clc;
close all;

% reply = input('Do you want more? Y/N [Y]: ', 's');
% if isempty(reply)
%     reply = 'Y';
% end

%% ask the user some questions
disp('I will ask you some questions so that I can calculate the scan parameters');


prompt={'Enter the matrix size for x^2:',...
        'Enter the colormap name:'};
name='Input for Peaks function';
numlines=1;
defaultanswer={'20','hsv'};
answr=inputdlg(prompt,name,numlines,defaultanswer);

options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';

answr=inputdlg(prompt,name,numlines,defaultanswer,options);


%Open prompt as cell array (from: http://tinyurl.com/6awr65
prompt={'Please input the Field of View you would like to achieve (in mm!) [4mm]:', ...
    'Please input the Detector witdh in pixels [1024px]', ...
    'Please input the Magnification-Factor [10x]. If you leave the input empty, I assume you want to perform a calibration and will ask you lateron about that.', ...  
    };

%name of the dialog box
name='Please Input the Parameters for the scan';
 
%number of lines visible for your input
numlines=1;
 
%the default answer
defaultanswer={'4.1','1024','10'};
 
%creates the dialog box. the user input is stored into a cell array
answer=inputdlg(prompt,name,numlines,defaultanswer);
 
%notice we use {} to extract the data from the cell array
FOV_um = answer{1};
DetectorWidth_px = answer{2}
Magnification = answer{3}
  Magnification + DetectorWidth_px
pixelsize = 0;
while isempty(pixelsize) || ( pixelsize < 0.3 )
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

Overlap_percent = 100;
while Overlap_percent > 25
    disp('Please input the Overlap that you`d like to have');
    Overlap_percent = input('between your projection images (in percent ranging from 5 to 25% overlap!) [15%]: ');
    if isempty(Overlap_percent)
        Overlap_percent = 15;
        Overlap_px = DetectorWidth_px * Overlap_percent / 100;
    else
        Overlap_px = DetectorWidth_px * Overlap_percent / 100;
    end
end

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
disp('---');
disp('I`m using this data for calculations:');
disp(['Binning is set to ' num2str(Binning) 'x' num2str(Binning)]);
disp(['FOV is set to '            num2str(FOV_um) 'um' ]);
disp(['Detector Width is set to ' num2str(DetectorWidth_px) 'px']);
disp(['The Overlap is set to '    num2str(Overlap_percent) '%']);
disp('---');

% do we need rings?
ImageSegmentWidth_px = DetectorWidth_px - Overlap_px;
SegmentNumber=ceil( FOV_um / pixelsize / ImageSegmentWidth_px);
disp(['We need ' num2str(SegmentNumber) ' Segments to cover your chosen FOV']);

if SegmentNumber == 2
    disp('i propose one simple 360-scan')
    InbeamPosition_um = [ ImageSegmentWidth_px / 2 , - ImageSegmentWidth_px / 2 ] .* pixelsize;
    RotationStartAngle = [  0,   0];
    RotationStopAngle  = [360, 360];
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
        SegmentNumber = SegmentNumber -2 ;
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

GlobalNumberOfProjections = flipud(unique(GlobalNumberOfProjections,'rows','first'));
rowsum = sum(GlobalNumberOfProjections,2);
quality = rowsum ./ rowsum(1) .* 100;

[sortedquality permutation] = sort(quality,'descend');
GlobalNumberOfProjections = GlobalNumberOfProjections(permutation,:);
rowsum = ( rowsum(permutation,:) + ( AmountOfDarks + AmountOfFlats) * size(GlobalNumberOfProjections,2) ) .* ExposureTime / 60;
GlobalTimeforScans = ( GlobalNumberOfProjections + AmountOfDarks + AmountOfFlats ) .* ExposureTime / 60;

figure
    plot(sortedquality,rowsum,'s')
    ylabel('estimated ScanTime [min]')
    xlabel('estimated ScanQuality [%]')
h=helpdlg('Choose 1 point from the plot','Protocol Selection'); 
uiwait(h);
[userx,usery] = ginput(1);

[mindiff minidx ] = min(abs(sortedquality - userx));
ScanWhichTheUserWants = GlobalNumberOfProjections(minidx,:);
h=helpdlg(['You`ve chosen protocol ' num2str(minidx) ' corresponding to ' num2str(size(GlobalNumberOfProjections,2)) ...
    ' scans with ' num2str(ScanWhichTheUserWants) ' projections.']);
uiwait(h);
dlmwrite('/afs/psi.ch/user/h/haberthuer/MATLAB/parameters.txt', ScanWhichTheUserWants, ' ') 
