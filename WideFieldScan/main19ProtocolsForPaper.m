tic
%% Simulation of different Protocols for wide-field-scanning
% Main file for WideFieldScan-Simulation
%
% the file can be started in the matlab console and then runs fully
% self-contained, as long as the necessary files are present

warning off Images:initSize:adjustingMag % suppress the warning about big images
clear; close all; clc;tic; disp(['It`s now ' datestr(now) ]);disp('-----');

if isunix
  addpath('/sls/X02DA/data/e11126/MATLAB/matlab2tikz');
else
  addpath('P:\MATLAB\matlab2tikz');
end

printit = 1;
ShowTheErrorFigures = 0;
SSIM = 0; % User SSIM to calculate the "Error". 0=DifferenceImage, 1=SSIM, 
writeas = '-dpng';

FOV_mm            = 4;  % This is the FOV the user wants to achieve
Binning           = 2;  % since the Camera is 2048px wide, the binning influences the DetectorWidth
Magnification     = 10;  % Magn. and Binning influence the pixelsize
ExposureTime      = 100;  % Exposure Time, needed for Total Scan Time estimation
Overlap_px        = 100;  % Overlap between the SubScans, needed for merging
MinimalQuality    = 16;  % minimal Quality for Simulation
MaximalQuality    = 100;  % maximal Quality for Simulation     
QualityStepWidth  = 4.6666;  % Quality StepWidth, generally 10%
SimulationSize_px = 64;  % DownSizing Factor for Simulation > for Speedup
writeout          = 1; % Do we write a PreferenceFile to disk at the end?
UserSampleName  = 'Paper';     % SampleName For OutputFile, now without str2num, since it's already a string...
Beamtime     = 'Paper';     % Beamtime-Name, used for the path for writing the preference-file

%% Calculations needed for progress
pixelsize = 7.4 / Magnification * Binning; % makes Pixel Size [um] equal to second table on TOMCAT website (http://is.gd/citz)

FOV_px = round( FOV_mm * 1000 / pixelsize); % mm -> um -> px
DetectorWidth_px= 2048 / Binning;  % The camera is 2048 px wide > FOV scales with binning

SegmentWidth_px = DetectorWidth_px - Overlap_px;    
AmountOfSubScans = ceil( FOV_px / SegmentWidth_px );  

pause(0.001);
disp([num2str(AmountOfSubScans) ' SubScans are needed to cover your chosen FOV']);

if mod(AmountOfSubScans,2) == 0 % AmountOfSubScans needs to be odd
    AmountOfSubScans = AmountOfSubScans +1;
    disp(['Since an odd Amount of SubScans is needed, we acquire ' num2str(AmountOfSubScans) ' SubScans.'])
end

ActualFOV_px = AmountOfSubScans * SegmentWidth_px; % this is the real actual FOV, which we aquire
disp(['Your sample could be ' num2str((ActualFOV_px*pixelsize/1000) - FOV_mm) ' mm wider and would still fit into this protocol...']);
disp(['Your sample could be ' num2str(ActualFOV_px - FOV_px) ' pixels wider and would still fit into this protocol...']);

NumberOfProjections = ...
    [ 5244, 5244, 5244;
	5244, 2622, 5244;
	4370, 4370, 4370;
    4370, 2185, 4370;
    3934, 3934, 3934;
    3934, 1967, 3934;
    3496, 3496, 3496;
    3496, 1748, 3496;    
    3060, 3060, 3060;
    3060, 1530, 3060;
    2622, 2622, 2622;
	2622, 1311, 2622;
	2186, 2186, 2186;
	2185, 1093, 2185;
	1748, 1748, 1748;
	1748,  874, 1748;
	1312, 1312, 1312; 
	 874,  874,  874;
	 874, 437,  874;]

AmountOfProtocols=size(NumberOfProjections,1);

for i=1:AmountOfProtocols
  TimePerProtocol(i) = NaN; % DUMMY FOR THE PAPER
end

TotalProjectionsPerProtocol = sum(NumberOfProjections,2)

[ dummy SortIndex ] = sort(TotalProjectionsPerProtocol);
pause(0.001);

% plot this table
figure
  plot(TotalProjectionsPerProtocol(SortIndex),'-o');
  xlabel('Protocol')
  ylabel('Total NumProj')
  set(gca,'XTick',[1:AmountOfProtocols])
  set(gca,'XTickLabel',SortIndex)
  grid on;

%% Simulating these Protocols to give the end-user a possibility to choose
% Use SimulationSize input at the beginning to reduce the calculations to
% this size, or else it just takes too long...
ModelReductionFactor = SimulationSize_px / ActualFOV_px;
ModelOverlap_px= round( Overlap_px * ModelReductionFactor );
MinimalOverlap = 3;
if ModelOverlap_px < MinimalOverlap % Overlap needs to be above 4 pixels to reliably calculate the merging.
  CorrectedReductionFactor = MinimalOverlap / Overlap_px ;
  h=helpdlg(['The Overlap for your chosen Model Size is ' num2str(ModelOverlap_px) ...
    ' px (=below ' num2str(MinimalOverlap) 'px). I`m thus redefining the Reduction Factor from ' ...
    num2str(round(ModelReductionFactor*1000)/1000) ' to ' num2str(round(CorrectedReductionFactor*1000)/1000) ],... %*1000/1000 is used to display 3 digits...
    'Tenshun!');
  SimulationSize_px = round( SimulationSize_px * CorrectedReductionFactor / ModelReductionFactor );
  ModelReductionFactor = CorrectedReductionFactor;
  ModelOverlap_px = round(Overlap_px * ModelReductionFactor);
  uiwait(h);
end
pause(0.001);

disp(['The actual FOV is ' num2str(ActualFOV_px) ' pixels, the set ModelSize is ' num2str(SimulationSize_px) ...
  ', we are thus reducing our calculations approx. ' num2str(round(1/ModelReductionFactor)) ' times.']);
pause(0.001);


ModelNumberOfProjections = round(NumberOfProjections .* ModelReductionFactor);
%ModelNumberOfProjections = NumberOfProjections;


disp('Generating ModelPhantom...');
usephantom = 0;
if usephantom == 1
    ModelImage = phantom( round( ActualFOV_px*ModelReductionFactor ) );
    ModelImage = imnoise(ModelImage,'gaussian',0,0.005);
    warndlg('using phantom for calculation');    
else
    ModelImage = imread('S:\SLS\2008c\mrg\R108C21Cb_mrg\original_rec_8bit\R108C21Cb_mrg1024.rec.8bit.tif');
%    ModelImage = imresize(ModelImage,[ ActualFOV_px*ModelReductionFactor NaN ]);
    warndlg('reading slice R108C21Cb_mrg1024.rec.8bit.tif as phantom');
end
ModelSize=size(ModelImage,1);

ModelDetectorWidth = round( DetectorWidth_px * ModelReductionFactor );
theta = 1:179/ModelNumberOfProjections(1):180;
disp('Calculating ModelSinogram...');
ModelMaximalSinogram = radon(ModelImage,theta);
disp('Calculating ModelReconstruction...');
ModelMaximalReconstruction = iradon(ModelMaximalSinogram,theta);

h = waitbar(0,'Simulating');
for Protocol = 1:size(ModelNumberOfProjections,1)
  waitbar(Protocol/size(ModelNumberOfProjections,1),h,['Working on Protocol ' num2str(Protocol) ' of ' num2str(size(ModelNumberOfProjections,1)) '.'])
  disp('---');
  disp(['Working on Protocol ' num2str(Protocol) ' of ' num2str(size(ModelNumberOfProjections,1)) '.']);
  % calculating the error to the original, fullsize protocol
  % uses ModelSinogram and current NumberOfProjections as input
  [ AbsoluteError(Protocol), ErrorPerPixel(Protocol) ] = ...
    fct_ErrorCalculation(ModelImage,ModelNumberOfProjections(Protocol,:),ModelMaximalReconstruction,SSIM,ShowTheErrorFigures);
  pause(0.001);
end
close(h)

%% Normalizing the Error
Quality = max(ErrorPerPixel) - ErrorPerPixel;
Quality = Quality ./ max(Quality) * ( MaximalQuality - MinimalQuality) + MinimalQuality;

FitFactor = 4;
figure
  ScanningTime = TotalProjectionsPerProtocol / max(TotalProjectionsPerProtocol) * 116;
  % Calculate fit parameters
  [FittedQuality,ErrorEst] = polyfit(ScanningTime,Quality',FitFactor);
  % Evaluate the fit
  EvalFittedQuality = polyval(FittedQuality,ScanningTime(SortIndex),ErrorEst);
  % Plot the data and the fit
  plot(ScanningTime(SortIndex),EvalFittedQuality,'-',ScanningTime(SortIndex),Quality(SortIndex),'o');
  xlabel('Time used [Percent of Gold Standard]');
  ylim([0 120]) 
  ylabel('Expected Quality of the Scan [Percent]');
  grid on;
  title('Quality plotted vs. sorted Total Number of Projections');
  %legend(['polynomial Fit (' num2str(FitFactor) ')'],'Protocols','Location','SouthEast')
  legend('polynomial Fit','Protocols','Location','SouthEast')
  if printit == 1
    if SSIM == 1
        Method = 'SSIM'
    elseif SSIM == 0
        Method = 'DiffImg'
    end
    File = [ num2str(sprintf('%04d',ModelSize)) 'px-Simulation-' Method 'VsScanningTime-forPaper' ];
    filename = [ 'P:\MATLAB\WideFieldScan\PaperPlots' filesep File ];
    print(writeas, filename);    
    filename = [ filename '.tex' ];
    matlab2tikz(filename);
  end
 
disp(['it took me approx. ' num2str(round(toc/60)) ' minutes to calculate everything...']);