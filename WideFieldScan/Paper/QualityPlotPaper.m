%% Simulation of different Protocols for wide-field-scanning
% Main file for WideFieldScan-Simulation, adapted to generate plot for the
% WideFieldScanPaper

warning off Images:initSize:adjustingMag % suppress the warning about big images
clear; close all; clc;tic; disp(['It`s now ' datestr(now) ]);disp('-----');

addpath('P:\MATLAB\matlab2tikz');
addpath('P:\MATLAB\WideFieldScan\');
cd('P:\MATLAB\WideFieldScan\Paper');

printit = 1;
SSIM = 0; %calculate conventional error with 0, use SSIM with 1
printdir = [ pwd filesep 'SimulationOutput' ];
[status,message,messageid] = mkdir(printdir); % stat, mess, messid: so we don't get an annoying message each time the directory exists...
writeas = '-dpng';

writeall = 1; % shall we write all protocols to disk or just the selected?
% 
% % User input and value extraction
% User Input is done via an Input Dialog (inputdlg)
% InputDialog={...
%     'FOV [mm]',...              % 1
%     'Binning',...               % 2
%     'Magnification',...         % 3
%     'Overlap [px]',...          % 4
%     'Exposure Time [ms]',...    % 5
%     'Minimal Quality [%]',...   % 6
%     'Maximal Quality [%]',...   % 7
%     'Quality Stepwitdh [%]',... % 8
%     'SimulationSize [px] (512 or 1024 is a sensible choice...)',... % 9
%     'Write a file with the final details to disk? (1=y,0=n)',...    % 10
%     'Sample Name (leave it empty and I`ll ask you later on...)',... % 11
%     };

% % Setup of the Dialog Box
% Name='Please Input the scan-parameters';
% NumLines=1; % Number of Lines for the Boxes

% % The default Answers are...
% Defaults={...
%     '4.1',...   % 1
%     '2',...     % 2
%     '10',...    % 3
%     '100',...   % 4
%     '90',...    % 5
%     '60',...    % 6
%     '100',...   % 7
%     '10',...     % 8
%     '150',...   % 9
%     '1',...     % 10
%     '2009c-Batch',... % 11
%     };
 
% % Creates the Dialog box. Input is stored in UserInput array
% UserInput=inputdlg(InputDialog,Name,NumLines,Defaults);
%  
% % Extract the answers from the array
% FOV_mm            = str2num(UserInput{1});  % This is the FOV the user wants to achieve
Binning           = 2;  % since the Camera is 2048px wide, the binning influences the DetectorWidth
Magnification     = 10;  % Magn. and Binning influence the pixelsize
Overlap_px        = 100;  % Overlap between the SubScans, needed for merging
ExposureTime      = 125;  % Exposure Time, needed for Total Scan Time estimation
MinimalQuality    = 20;  % minimal Quality for Simulation
MaximalQuality    = 100;  % maximal Quality for Simulation     
% QualityStepWidth  = str2num(UserInput{8});  % Quality StepWidth, generally 10%
SimulationSize_px = 1000; %;  % DownSizing Factor for Simulation > for Speedup
% writeout          = str2num(UserInput{10}); % Do we write a PreferenceFile to disk at the end?
% UserSampleName    = UserInput{11};          % SampleName For OutputFile, now without str2num, since it's already a string...

% %% Calculations needed for progress
pixelsize = 7.4 / Magnification * Binning; % makes Pixel Size [um] equal to second table on TOMCAT website (http://is.gd/citz)
% 
FOV_px = 3072;%round( FOV_mm * 1000 / pixelsize); % mm -> um -> px
DetectorWidth_px= 2048 / Binning;  % The camera is 2048 px wide > FOV scales with binning
% 
SegmentWidth_px = DetectorWidth_px - Overlap_px;
AmountOfSubScans = ceil( FOV_px / SegmentWidth_px );  
% 
% pause(0.001);disp([num2str(AmountOfSubScans) ' SubScans are needed to cover your chosen FOV']);
% if mod(AmountOfSubScans,2) == 0 % AmountOfSubScans needs to be odd
%     AmountOfSubScans = AmountOfSubScans +1;
%     disp(['Since an odd Amount of SubScans is needed, we acquire ' num2str(AmountOfSubScans) ' SubScans.'])
% end

ActualFOV_px = AmountOfSubScans * SegmentWidth_px; % this is the real actual FOV, which we aquire
% disp(['Your sample could be ' num2str((ActualFOV_px*pixelsize/1000) - FOV_mm) ' mm wider and would still fit into this protocol...']);
% disp(['Your sample could be ' num2str(ActualFOV_px - FOV_px) ' pixels wider and would still fit into this protocol...']);

%% Generate 'Table' with Number of Projections
NumberOfProjections = [...
    5244, 5244, 5244;...
    5244, 2622, 5244;...
    4370, 4370, 4370;...
    4370, 2185, 4370;...
    3934, 3934, 3934;...
    3934, 1967, 3934;...
    3496, 3496, 3496;...
    3496, 1748, 3496;...
    3060, 3060, 3060;...
    3060, 1530, 3060;...
    2622, 2622, 2622;...
    2622, 1311, 2622;...
    2186, 2186, 2186;...
    2185, 1093, 2185;...
    1748, 1748, 1748;...
    1748, 874, 1748;...
    1312, 1312, 1312;...
    874, 874, 874;...
    874, 437, 874 ];
AmountOfProtocols=size(NumberOfProjections,1);

for i=1:AmountOfProtocols
    TimePerProtocol(i) = fct_HowLongDoesItTake(ExposureTime,NumberOfProjections(i,:));
end

TotalProjectionsPerProtocol = sum(NumberOfProjections,2);

[ dummy SortIndex ] = sort(TotalProjectionsPerProtocol);
pause(0.001);

% plot this table
figure
    plot(TotalProjectionsPerProtocol(SortIndex),'-o');
    xlabel('Protocol')
    ylabel('Total NumProj')
    set(gca,'XTick',[1:AmountOfProtocols])
    set(gca,'XTickLabel',SortIndex)    
    if printit == 1
        File = [ 'TotalProjectionsPlot' ];
        filename = [ printdir filesep File ];
        print(writeas, filename);        
        filename = [ filename '.tex' ];
        matlab2tikz(filename);
    end  

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
disp('Generating ModelPhantom...');
ModelImage = phantom( round( ActualFOV_px*ModelReductionFactor ) );
ModelSize=size(ModelImage,1);
ModelImage = imnoise(ModelImage,'gaussian',0,0.005);
ModelDetectorWidth = round( DetectorWidth_px * ModelReductionFactor );
theta = 1:179/ModelNumberOfProjections(1):180;
disp('Calculating ModelSinogram...');
ModelMaximalSinogram = radon(ModelImage,theta);
disp('Calculating ModelReconstruction...');
ModelMaximalReconstruction = iradon(ModelMaximalSinogram,theta);

h = waitbar(0,['Simulating']);
for Protocol = 1:size(ModelNumberOfProjections,1)
    waitbar(Protocol/size(ModelNumberOfProjections,1),h,['Working on Protocol ' num2str(Protocol) ' of ' num2str(size(ModelNumberOfProjections,1)) '.'])
    disp('---');
    disp(['Working on Protocol ' num2str(Protocol) ' of ' num2str(size(ModelNumberOfProjections,1)) '.']);
    % calculating the error to the original, fullsize protocol
    % uses ModelSinogram and current NumberOfProjections as input
    ShowTheFigures = 0;
    [ AbsoluteError(Protocol), ErrorPerPixel(Protocol) ] = ...
        fct_ErrorCalculation(ModelImage,ModelNumberOfProjections(Protocol,:),ModelMaximalReconstruction,SSIM,ShowTheFigures);
    pause(0.001);
end
close(h)

%% Normalizing the Error
Quality = max(ErrorPerPixel) - ErrorPerPixel;
Quality = Quality ./ max(Quality) * ( MaximalQuality - MinimalQuality ) + MinimalQuality;

% %% display error
% figure
%     plot(TotalProjectionsPerProtocol(SortIndex),AbsoluteError(SortIndex),'-o');
%     xlabel(['Total Number Of Projections per Protocol']);
% 	ylabel('$$\sum\sum$$(imabsdiff(Phantom-Reconstruction)) [au]','Interpreter','latex');
%     grid on;
%     title('Absolute Error, sorted with Total Number of Projections');
%     if printit == 1
%         File = [ num2str(ModelSize) 'px-Plot-AbsoluteErrorVsTotalProjections' ];
%         filename = [ printdir filesep File ];
%         print(writeas, filename);
%         filename = [ filename '.tex' ];
%         matlab2tikz(filename);
%     end

% figure
%     plot(TotalProjectionsPerProtocol(SortIndex),ErrorPerPixel(SortIndex),'-o');
%     xlabel(['Total Number Of Projections per Protocol']);
% 	ylabel('Expected Quality of the Scan [au]');
%     grid on;
%     title('Error per Pixel, sorted with Total Number of Projections');
%     if printit == 1
%         File = [ num2str(ModelSize) 'px-Plot-ErrorPerPixelVsTotalProjections' ];
%         filename = [ printdir filesep File ];
%         print(writeas, filename);        
%         filename = [ filename '.tex' ];
%         matlab2tikz(filename);
%     end
    
FitFactor = 5;
figure
    ScanningTime = TotalProjectionsPerProtocol * ExposureTime / 1000 / 60;
        
    disp('------');
    disp('------');
    disp('redefining scanning time');
    disp('------');
    disp('------');
    ScanningTimeGoldStandard = 15890 * ExposureTime / 1000 / 60; % 
    ScanningTime = ScanningTime ./ ScanningTimeGoldStandard * 100;
    
    % Calculate fit parameters
    [FittedQuality,ErrorEst] = polyfit(ScanningTime,Quality',FitFactor);
    % Evaluate the fit
    EvalFittedQuality = polyval(FittedQuality,ScanningTime(SortIndex),ErrorEst);
    % Plot the data and the fit
    plot(ScanningTime(SortIndex),EvalFittedQuality,'-',ScanningTime(SortIndex),Quality(SortIndex),'o');
    xlabel(['Scanning Time [% of Gold Standard]']);
    ylim([0 120]) 
    ylabel('Expected Quality of the Scan [%]');
    grid on;
    title('Quality plotted vs. sorted Total Number of Projections');
    %legend(['polynomial Fit (' num2str(FitFactor) ')'],'Protocols','Location','SouthEast')
    legend(['polynomial Fit'],'Protocols','Location','SouthEast')
    if printit == 1
        File = [ num2str(ModelSize) 'px-Plot-QualityVsScanningTimeFit' ];
        filename = [ printdir filesep File ];
        print(writeas, filename);        
        filename = [ filename '.tex' ];
        matlab2tikz(filename);
    end

% figure
%     plot(ScanningTime(SortIndex),Quality(SortIndex),'-o');
%     xlabel(['Scanning Time [% of Gold Standard]']);
%     ylim([0 120]) 
%     ylabel('Expected Quality of the Scan [%]');
%     grid on;
%     title('Quality plotted vs. sorted Total Number of Projections');
%     if printit == 1
%         File = [ num2str(ModelSize) 'px-Plot-QualityVsScanningTime' ];
%         filename = [ printdir filesep File ];
%         print(writeas, filename);        
%         filename = [ filename '.tex' ];
%         matlab2tikz(filename); 
%     end
    
% figure
%     plot(SortIndex,Quality(SortIndex),'o');
%     xlabel(['Total Proj']);
%     ylabel('Quality')
%     ylim([0 120]) 
%     title('Quality plotted vs. Total Proj.');
%     interval = 4;
%     set(gca,'XTick',[1:interval:AmountOfProtocols])
%     set(gca,'XTickLabel',TotalProjectionsPerProtocol(1:interval:end))
%     if printit == 1
%         File = [ num2str(ModelSize) 'px-Plot-QualityVsTotalProjections' ];
%         filename = [ printdir filesep File ];
%         print(writeas, filename);        
%         filename = [ filename '.tex' ];
%         matlab2tikz(filename);
%     end 

% figure
%     plot(fliplr(SortIndex),Quality(SortIndex),'o');
%     xlabel('Protocol')
%     ylabel('Quality')
%     ylim([0 120]) 
%     title('Quality plotted vs. Protocol Number');
%     set(gca,'XTick',[1:AmountOfProtocols])
%     set(gca,'XTickLabel',34-SortIndex)
%     if printit == 1
%         File = [ num2str(ModelSize) 'px-Plot-QualityVsProtocols' ];
%         filename = [ printdir filesep File ];
%         print(writeas, filename);        
%         filename = [ filename '.tex' ];
%         matlab2tikz(filename);
%     end    

if writeall == 0    
    %% Let the user choose a protocol
    h=helpdlg(['Choose 1 circle from the plot (quality vs. total scan-time!). ' ...
        'One circle corresponds to one possible protocol. Take a good look ' ...
        'at the time vs. the quality . I`ll then calculate the protocol that '...
        'best fits your choice']); 
    uiwait(h);
    [ userx, usery ] = ginput(1);
    [ mindiff minidx ] = min(abs(ScanningTime - userx));
    % SortedNumProj = NumberOfProjections(SortIndex,:);
    % UserNumProj = SortedNumProj(minidx,:);
    UserNumProj = NumberOfProjections(minidx,:);
end

% %% write the UserNumProj to disk, so we can use it with
% %% widefieldscan_final.py
% if writeout == 1
%     % Hardcode path
% %        UserPath = printdir;
%          UserPath = '/sls/X02DA/Data10/e11126/2009c'  
%     % choose the path
% %      h=helpdlg('Please choose a path where I should write the output-file'); 
% %      uiwait(h);
% %      UserPath = uigetdir;
% %      pause(0.01);
%     % input samplename
%     filename = [UserPath filesep UserSampleName '.txt' ];
%     if isempty(UserSampleName)
%         UserSampleName = input('Now please input a SampleName: ', 's');
%     end
%    
%     % calculate InbeamPosition
%     SegmentWidth_um = SegmentWidth_px * pixelsize;
%     UserInbeamPosition=ones(AmountOfSubScans,1);
%     for position = 1:length(UserInbeamPosition)
%         UserInbeamPosition(position) = SegmentWidth_um * position - ( ceil ( length(UserInbeamPosition)/2) * SegmentWidth_um);
%     end
%     % set angles
%     RotationStartAngle = 0;
%     RotationStopAngle  = 180;
% 
%     % write Header to textfile 'filename'
%     % depending on the platform
%     dlmwrite(filename, ['# Path = ' UserPath],'delimiter','');
%     dlmwrite(filename, ['# SampleName = ' UserSampleName],'-append','delimiter','');
%     dlmwrite(filename, ['# chosen FOV = ' num2str(FOV_mm) ' mm'],'-append','delimiter','');
%     dlmwrite(filename, ['# chosen FOV = ' num2str(FOV_px) ' pixels'],'-append','delimiter','');
%     dlmwrite(filename, ['# actual FOV = ' num2str(ActualFOV_px) ' pixels'],'-append','delimiter','');
%     dlmwrite(filename, ['# DetectorWidth = ' num2str(DetectorWidth_px) ' pixels'],'-append','delimiter','');
%     dlmwrite(filename, ['# Exposure Time = ' num2str(ExposureTime) ' ms per Projection'],'-append','delimiter','');
%     dlmwrite(filename, ['# Magnification = ' num2str(Magnification) ' x'],'-append','delimiter','');
%     dlmwrite(filename, ['# Binning = ' num2str(Binning) ' x ' num2str(Binning)],'-append','delimiter','');
%     dlmwrite(filename, ['# Overlap = ' num2str(Overlap_px) ' pixels'],'-append','delimiter','');
%     if writeall == 1
%         h=helpdlg(['I am now writing ALL (!) protocols to disk in the file "' filename '".']);
%         dlmwrite(filename, '#---','-append','delimiter','');
%         dlmwrite(filename, '# NumProj InBeamPosition StartAngle StopAngle','-append','delimiter','');
%         for i=1:AmountOfProtocols  
%             UserNumProj = NumberOfProjections(i,:);
%             % NumProj to first column of output
%             OutputMatrix(:,1)=UserNumProj;
%             % InbeamPositions to second column of output
%             OutputMatrix(:,2)=UserInbeamPosition;
%             % Start and Stop Angles to third and fourth column of output
%             OutputMatrix(:,3)=RotationStartAngle;
%             OutputMatrix(:,4)=RotationStopAngle;
%             dlmwrite(filename, [ '#--- Protocol ' num2str(i) '/' ...
%                 num2str(TotalProjectionsPerProtocol(i)) ' total Proj./' ...
%                 num2str(TimePerProtocol(i)) ' minutes ---'],'-append','delimiter','');
%             dlmwrite(filename, [OutputMatrix],  '-append', 'delimiter', ' ');
%         end
%     elseif writeall == 0
%         h=helpdlg(['You have chosen protocol ' num2str(minidx) ' corresponding to ' ...
%             num2str(size(NumberOfProjections,2)) ' scans with NumProj like this: ' ...
%             num2str(UserNumProj) ' as a best match to your selection. I am now writing ' ...
%             'this protocol to disk in the file "' filename '".']);
%         dlmwrite(filename, ['# Chosen Protocol = Nr. ' num2str(minidx) ],'-append','delimiter','');
%         dlmwrite(filename, '#---','-append','delimiter','');
%         dlmwrite(filename, '# NumProj InBeamPosition StartAngle StopAngle','-append','delimiter','');
%         % UserNumProj is already set above, so we don't need to re-set
%         % it...
%         % NumProj to first column of output
%         OutputMatrix(:,1)=UserNumProj;
%         % InbeamPositions to second column of output
%         OutputMatrix(:,2)=UserInbeamPosition;
%         % Start and Stop Angles to third and fourth column of output
%         OutputMatrix(:,3)=RotationStartAngle;
%         OutputMatrix(:,4)=RotationStopAngle;
%         dlmwrite(filename, [ '#--- Protocol ' num2str(minidx) '/' ...
%             num2str(TotalProjectionsPerProtocol(minidx)) ' total Proj./'...
%             num2str(TimePerProtocol(minidx)) ' ---#'],'-append','delimiter','');
%         dlmwrite(filename, [OutputMatrix],  '-append', 'delimiter', ' ');
%     end % writeall
% end % writeout

%% finish
disp('-----');
disp('I`m done with all you`ve asked for...');
disp(['It`s now ' datestr(now) ]);
zyt=toc;sekunde=round(zyt);minute = floor(sekunde/60);stunde = floor(minute/60);
if stunde >= 1
    minute = minute - 60*stunde;
    sekunde = sekunde - 60*minute - 3600*stunde;
    disp(['It took me approx ' num2str(round(stunde)) ' hours, ' ...
        num2str(round(minute)) ' minutes and ' num2str(round(sekunde)) ...
        ' seconds to perform the given task' ]);
else
    minute = minute - 60*stunde;
    sekunde = sekunde - 60*minute;
    disp(['It took me approx ' num2str(round(minute)) ' minutes and ' ...
        num2str(round(sekunde)) ' seconds to perform the given task' ]);
end

% close all;

%helpdlg('I`m done with all you`ve asked for...','Phew!');