%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rebuild of the Merging functions 
% Hopefully more clever implementation with parsing of logfiles and
% using most of the available stuff 
% Initial Version: 3.6.2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;clear all;close all;tic;
WasDir = pwd;

%% Setup
BeamTime = '2011a';
DataDir = 'Data10';
Drive = 'R'; % Setup for Windows
OutPutTifDirName = 'tif';
ReadLinesOfLogFile = 33; % Lines to read for the Logfile, so we don't read in everything
CutlineValue = [];% Set to something non-empty if youy do not want to let MATLAB to calculate the cultline

%% Ask the User what SubScans we should merge
h=helpdlg('Select the logfile of the FIRST SubScan I should merge. Look in the "log" folder of the BeamTime!',...
	'Instructions');
uiwait(h);
pause(0.01);
if isunix==0
    StartPath = [ Drive ':' filesep 'SLS' filesep BeamTime filesep ];
else
    StartPath = [ filesep 'sls' filesep 'X02DA' filesep 'data' filesep 'e11126' filesep DataDir filesep BeamTime filesep 'log' ];  
end
disp(['Opening ' StartPath ' to look for Logfiles'])
[ LogFile, LogFilePath] = uigetfile({'*.log','LogFiles (*.log)'},...
    'Pick the FIRST LogFile',[ StartPath filesep 'LogFile.log' ]);
[ SubScan Starting Ending] = regexp(LogFile, '_s1', 'match', 'start', 'end');

%% See how many LogFiles we're having...
for i=1:7
    fid = fopen([ LogFilePath LogFile(1:Starting-1) '_s' num2str(i) ...
        LogFile(Ending+1:end) ]);
    if fid==-1
        disp([ 'Logfile ' LogFile(1:Starting-1) '_s' num2str(i) LogFile(Ending+1:end) ...
            ' does not exist'])
        AmountOfSubScans = i-1;
        if i==1
            disp('Did you really click on the first Logfile?')
        end
        break
    else
        disp([ 'Logfile ' LogFile(1:Starting-1) '_s' num2str(i) LogFile(Ending+1:end) ...
            ' found'])
    end
    if fid ==-1 && i==1
        disp('FUCK')
        break
    end
end
disp([ 'I have found ' num2str(AmountOfSubScans) ' logfiles which seem to belong together in ' ...
    LogFilePath ])
if AmountOfSubScans == 0
    disp('Quitting')
    break
end
Data(AmountOfSubScans).Dummy = NaN; % preallocate Structure for Speed-purposes
for i=1:AmountOfSubScans
    disp(['-' LogFile(1:Starting-1) '_s' num2str(i) LogFile(Ending+1:end) ]);
    Data(i).LogFileLocation = [ LogFilePath LogFile(1:Starting-1) '_s' ...
        num2str(i) LogFile(Ending+1:end) ];
	Data(i).LogFileName = [ LogFile(1:Starting-1) '_s' num2str(i) ...
        LogFile(Ending+1:end) ];
    Data(i).SubScanName = [ LogFile(1:Starting+1) num2str(i) LogFile(Ending+1:end-4) ];
end
disp('---')

%% Manually set cutlines
Data(1).CutlineFirstProjections = CutlineValue;
Data(1).CutlineLastProjections = Data(1).CutlineFirstProjections;
Data(2).CutlineFirstProjections = Data(1).CutlineFirstProjections;
Data(2).CutlineLastProjections = Data(1).CutlineFirstProjections;

%% Read Logfile for parsing the needed Data
% (from http://is.gd/cAYfT)
for i=1:AmountOfSubScans
    disp(['Extracting Data from ' Data(i).LogFileName ]);
    fid = fopen(Data(i).LogFileLocation);
    LogFile = textscan(fid,'%s',ReadLinesOfLogFile,'delimiter','\n');
    LogFile = LogFile{1};
    TMP = regexp(LogFile, ':', 'split');
    % Above line splits LogFile-lines at ':' so we can extract the values
    % get Values and strip leading and trailing spaces
    Data(i).UserID = strtrim(TMP{1}{2});
    Data(i).RingCurrent = str2double(strtrim(TMP{4}{2}));
    Data(i).BeamEnergy = str2double(strtrim(TMP{5}{2}));
    Data(i).Mono = strtrim(TMP{6}{2});
    Data(i).Objective = str2double(strtrim(TMP{8}{2}));
    Data(i).Scintillator = strtrim(TMP{9}{2});
    Data(i).ExposureTime = str2double(strtrim(TMP{10}{2}));
    Data(i).SampleFolder = strtrim(TMP{12}{2});
    Data(i).NumProjections = str2double(strtrim(TMP{14}{2}));
    Data(i).NumDarks = str2double(strtrim(TMP{15}{2}));
    Data(i).NumFlats = str2double(strtrim(TMP{16}{2}));     
    Data(i).InterFlats = str2double(strtrim(TMP{17}{2}));
    Data(i).InnerScan = str2double(strtrim(TMP{18}{2}));
    Data(i).FlatFreq = str2double(strtrim(TMP{19}{2}));
    Data(i).RotYmin = str2double(strtrim(TMP{20}{2}));
    Data(i).RotYmax = str2double(strtrim(TMP{21}{2}));
    Data(i).AngularStep = str2double(strtrim(TMP{22}{2}));
    Data(i).SampleIn = str2double(strtrim(TMP{23}{2}));
    Data(i).SampleOut = str2double(strtrim(TMP{24}{2}));    
end
disp('---');

%% Display Some Information to User
% Merging
if AmountOfSubScans == 3
    disp('According to the Logfiles we recorded:');      
    for i=1:AmountOfSubScans
        disp([ num2str(Data(i).NumProjections) ' Projections, ' ...
            num2str(Data(i).NumDarks) ' Darks and '...
            num2str(Data(i).NumFlats) ' Flats for SubScan ' ...
            Data(i).SubScanName]);      
    end
else
    disp('Merging for other amount than 3 SubScans not implemented yet, sorry.');
    disp('Quitting');
    break
end

% Projections
Interpolation(1) = 1;
Interpolation(2) = Data(1).NumProjections / Data(2).NumProjections;
Interpolation(3) = 1;
if Interpolation(2) == 1
    disp('SubScans _s1 and _s2 have an equal amount of Projections.')
    disp('No Interpolation necessary while merging');
else
    disp('SubScans _s1 and _s2 have a different amount of Projections.')
    disp('We thus need to interpolate the files during merging');
    disp([ 'with a factor from SubScan _s1 to _s2 of ' num2str(Interpolation(2)) ])
end
disp('---');

%% Construct Paths to read the Files
if isunix == 1
    disp('We probably are @SLS, using Location from Logfiles')
else
    disp('We probably are @Unibe, constructing new File-Locations')
    for i=1:AmountOfSubScans        
        Data(i).SampleFolder = [ Drive ':' filesep 'SLS' filesep BeamTime ...
            filesep Data(i).SubScanName ];     
    end
end
disp('---');

%% Make Output-Directory
disp('Extracting Directory-Names of Projections from all Subscans, making OutpuDirectory')
[ TMP Starting Ending ] = regexp(LogFilePath, 'log', 'match', 'start', 'end');
OutputDirectory = LogFilePath(1:Starting-1);
[ s1 Starting Ending ] = regexp(Data(1).LogFileName, '_s1', 'match', 'start', 'end');
MergedScanName = [ Data(1).LogFileName(1:Starting) Data(1).LogFileName(Starting+4:end-4) 'mrg'];
OutputDirectory = [OutputDirectory MergedScanName ];
[ success,message] = mkdir([OutputDirectory filesep OutPutTifDirName ]);
disp([ 'and then finally resort Files into ' OutputDirectory]);
disp('---');

if Data(1).NumDarks + Data(1).NumFlats + Data(1).NumProjections ...
    + Data(1).NumProjections + Data(1).NumProjections + Data(3).NumFlats > 9999
    Decimal = '%05d';
else
    Decimal = '%04d';
end

%% Load Darks and Flats
LoadOneDarkAndFlat = 1;
% To Speed Things up we only load ONE Dark and Flat for Cutline Detection... (set to 1!)
for i=1:AmountOfSubScans
    if LoadOneDarkAndFlat == 1
        disp(['Loading Dark Nr. ' num2str(round(Data(i).NumDarks/2)) ' and Flat Nr. '...
            num2str(round(Data(i).NumFlats/2)) ' for ' Data(i).SubScanName ]);
        Data(i).AverageDark = double(imread([Data(i).SampleFolder filesep ...
            'tif' filesep Data(i).SubScanName sprintf('%04d',round(Data(i).NumDarks/2)) '.tif' ]));
        Data(i).AverageFlat = double(imread([Data(i).SampleFolder filesep ...
            'tif' filesep Data(i).SubScanName sprintf('%04d',round(Data(i).NumFlats/2)) ...
            '.tif' ]));
    else
        disp(['Loading ALL Darks and Flats for ' Data(i).SubScanName ]);
        DarkBar = waitbar(0,[ 'Loading ' num2str(Data(i).NumDarks) ...
            ' Darks for SubScan ' num2str(i)],'name','Please Wait...');
        for k=1:Data(i).NumDarks
            Data(i).Dark(:,:,k) = double(imread([Data(i).SampleFolder filesep ...
                'tif' filesep Data(i).SubScanName sprintf('%04d',k) '.tif' ]));
            waitbar(k/Data(i).NumDarks,DarkBar);
        end
        close(DarkBar)
        FlatBar = waitbar(0,[ 'Loading ' num2str(Data(i).NumFlats) ...
            ' Flats for SubScan ' num2str(i)],'name','Please Wait...');
        for k=1:Data(i).NumFlats
            Data(i).Flat(:,:,k) = double(imread([Data(i).SampleFolder filesep ...
                'tif' filesep Data(i).SubScanName sprintf('%04d',k+Data(i).NumDarks) ...
                '.tif' ]));
            waitbar(k/Data(i).NumFlats,FlatBar);
        end
        close(FlatBar)
        % Average Darks & Flats
    end % LoadOneDarkAndFlat
end % i=1:AmountOfSubScans

if LoadOneDarkAndFlat == 0 % Average Darks and Flats if we have multiple ones...
    for i=1:AmountOfSubScans
        disp(['Averaging Darks and Flats for SubScan s' num2str(i) ]);
        Data(i).AverageDark = mean(Data(i).Dark,3);
        Data(i).AverageFlat = mean(Data(i).Flat,3);
    end
end

% Show Darks * Flats
figure('name','Darks and Flats')
    for i=1:AmountOfSubScans
        subplot(2,3,i)
            imshow(Data(i).AverageDark,[])
            title(['avg. Dark _s' num2str(1)],'Interpreter','none')
        subplot(2,3,i+3)
            imshow(Data(i).AverageFlat,[])
            title(['avg. Flat _s' num2str(1)],'Interpreter','none')
    end
disp('---');

%% Calculating Cutlines
disp('Calculating Cutlines, this will take some time...');
for i=1:AmountOfSubScans
    % Load First Projection
    Data(i).ProjectionNumberFirst = Data(1).NumDarks + Data(1).NumFlats + 1;
    disp([ 'Reading Projection ' num2str(Data(i).ProjectionNumberFirst) ...
        ' of ' Data(i).SubScanName  ]);
    Data(i).ProjectionFirst = imread([Data(i).SampleFolder filesep 'tif' ...
        filesep Data(i).SubScanName num2str(sprintf('%04d',Data(i).ProjectionNumberFirst)) ...
        '.tif' ]);
    Data(i).ProjectionFirst = double(Data(i).ProjectionFirst);
    Data(i).CorrectedProjectionFirst = log(Data(i).AverageFlat - Data(i).AverageDark) - log(Data(i).ProjectionFirst - Data(i).AverageDark);  
    % Load Last Projection
    Data(i).ProjectionNumberLast = Data(1).NumDarks + Data(1).NumFlats + Data(i).NumProjections;
    disp([ 'Reading Projection ' num2str(Data(i).ProjectionNumberLast) ' of ' Data(i).SubScanName  ]);
    Data(i).ProjectionLast = imread([Data(i).SampleFolder filesep 'tif' ...
        filesep Data(i).SubScanName num2str(sprintf('%04d',Data(i).ProjectionNumberLast)) '.tif' ]);
    Data(i).ProjectionLast = double(Data(i).ProjectionLast);
    Data(i).CorrectedProjectionLast = log(Data(i).AverageFlat - Data(i).AverageDark) - log(Data(i).ProjectionLast - Data(i).AverageDark);
end

if isempty(Data(1).CutlineFirstProjections)
    disp('Calculating Cutlines, this will take some time...');
    for i=1:AmountOfSubScans-1
        disp(['Calculating cutline between SubScans s' num2str(i) ' and s' ...
            num2str(i+1) ' for projection ' num2str(Data(i).ProjectionNumberFirst) ]);
        Data(i).CutlineFirstProjections = function_cutline(Data(i).CorrectedProjectionFirst,Data(i+1).CorrectedProjectionFirst);
        disp(['Calculating cutline between SubScans s' num2str(i) ' and s' ...
            num2str(i+1) ' for projection ' num2str(Data(i).ProjectionNumberLast) ]);
        Data(i).CutlineLastProjections = function_cutline(Data(i).CorrectedProjectionLast,Data(i+1).CorrectedProjectionLast);
        if Data(i).CutlineFirstProjections < 0
            Data(i).CutlineFirstProjections = 1;
        end
        if Data(i).CutlineLastProjections < 0
            Data(i).CutlineLastProjections = 1;
        end
    end
else
    disp('Cutlines have been set manually...');
end

% Calculate merged Projections for Display Purposes
Data(1).MergedProjectionFirst = [ Data(1).CorrectedProjectionFirst(:,1:end-Data(1).CutlineFirstProjections) ...
    Data(2).CorrectedProjectionFirst Data(3).CorrectedProjectionFirst(:,Data(2).CutlineFirstProjections:end) ];
Data(1).MergedProjectionLast = [ Data(1).CorrectedProjectionLast(:,1:end-Data(1).CutlineLastProjections) ...
    Data(2).CorrectedProjectionLast Data(3).CorrectedProjectionLast(:,Data(2).CutlineLastProjections:end) ];

figure('name','Single and merged projections')%,'position',[150 300 1400 500])
    for i=1:AmountOfSubScans
        subplot(2,6,i)
            imshow(Data(i).CorrectedProjectionFirst,[])
            title([ Data(i).SubScanName num2str(sprintf('%04d',Data(i).ProjectionNumberFirst)) ],'interpreter','none')
        subplot(2,6,i+3)
            imshow(Data(i).CorrectedProjectionLast,[])
            title([ Data(i).SubScanName num2str(sprintf('%04d',Data(i).ProjectionNumberLast)) ],'interpreter','none')
    end
    subplot(2,6,7:9)
        imshow(Data(1).MergedProjectionFirst,[])
        title([ MergedScanName num2str(sprintf('%04d',Data(i).ProjectionNumberFirst)) ...
            ', Cutlines: ' num2str(Data(1).CutlineFirstProjections) '/' ...
            num2str(Data(2).CutlineFirstProjections) ],'interpreter','none')
    subplot(2,6,10:12)
        imshow(Data(1).MergedProjectionLast,[])
        title([ MergedScanName num2str(sprintf('%04d',Data(i).ProjectionNumberLast)) ...
            ', Cutlines: ' num2str(Data(1).CutlineLastProjections) '/' ...
            num2str(Data(2).CutlineLastProjections) ],'interpreter','none')
disp('---');

%% SanityCheck of the Cutlines
for i=1:AmountOfSubScans-1
    if Data(i).CutlineFirstProjections ~= Data(i).CutlineLastProjections
        disp([ 'Cutlines for the first and last projection for SubScan s' ...
            num2str(i) ' do not agree (' num2str(Data(i).CutlineFirstProjections) ' vs. ' ...
            num2str(Data(i).CutlineLastProjections) '),'])
        WithinPixel = 2;
        if abs(Data(i).CutlineFirstProjections - Data(i).CutlineLastProjections) <= WithinPixel
            disp([ 'but lie within ' num2str(WithinPixel) ' pixels of each other.'])
            Data(i).Cutline = round(mean([Data(i).CutlineFirstProjections,Data(i).CutlineLastProjections]));
            disp(['We thus use their mean and the new cutline between SubScan s' ...
                num2str(i) ' and s' num2str(i+1) ' is: ' num2str(Data(i).Cutline) ])
        else
            disp([ 'and are not within ' num2str(WithinPixel) ' pixels of each other.'])
            warndlg([ 'Cutlines for first and last projection differ for more than ' ...
                num2str(WithinPixel) ' pixels, we thus need to enter them manually!'],'!! Warning !!')
            disp(['Please enter new cutline between SubScan s' num2str(i) ' and s'...
                num2str(i+1) ])
            Data(i).Cutline = input('[px] ');
        end
    else
        disp([ 'Cutlines for the first and last projection for SubScan s' ...
            num2str(i) ' are the same (' num2str(Data(i).CutlineFirstProjections) ' vs. ' ...
            num2str(Data(i).CutlineLastProjections) '), so we proceed with these...'])
            Data(i).Cutline = Data(i).CutlineFirstProjections;
    end
end
disp('---');

%% Give out Cutlines, so User can control them
for i=1:AmountOfSubScans-1
	disp([ 'Using ' num2str(Data(i).Cutline) 'px as cutline between ' ...
        Data(i).SubScanName ' and ' Data(i+1).SubScanName ])
end
disp('---');

%% Resorting Files
if isunix
    what = 'Hardlink';
    do = 'ln';
else
    what = 'Copy';
    do = 'cp';
end
disp([ what 'ing Files to Merge-Directory' ]);
for i=1:AmountOfSubScans
    disp(['Working on SubScan s' num2str(i) ]);
	% Generate Counter for shuffling files
	ResortBar = waitbar(0,['Resorting ' num2str((Data(i).NumDarks + Data(i).NumFlats + Data(i).NumProjections + Data(i).NumFlats)) ' files for SubScan s' num2str(i)],'name','Please Wait...'); 
	for k=1:Data(i).NumDarks+Data(i).NumFlats+Data(i).NumProjections+Data(i).NumFlats
        if k <= Data(i).NumDarks+Data(i).NumFlats % Pre-Projection
            Counter = k;
        elseif ( k>Data(i).NumDarks+Data(i).NumFlats && k<=Data(i).NumDarks+Data(i).NumFlats+Data(i).NumProjections ) % Projections
            Counter = Data(i).NumDarks + Data(i).NumFlats + ( ( k - Data(i).NumDarks- Data(i).NumFlats ) * Interpolation(i) ) ;
            if i==2
                Counter = Counter -1;
            end
        else
            Counter = k + ((Interpolation(i)-1)*Data(i).NumProjections); % Post-Projections
        end
        OriginalFile = [Data(i).SampleFolder filesep 'tif' filesep Data(i).SubScanName num2str(sprintf('%04d',k)) '.tif' ];
        DestinationFile = [ OutputDirectory filesep OutPutTifDirName filesep MergedScanName num2str(sprintf(Decimal,(AmountOfSubScans*Counter)-(AmountOfSubScans-i))) '.tif' ];
        ResortCommand = [ do ' ' OriginalFile ' ' DestinationFile ];
        waitbar(k/(Data(i).NumDarks + Data(i).NumFlats + Data(i).NumProjections + Data(i).NumFlats));
        % disp(ResortCommand);
        [status,result] = system(ResortCommand);
    end
    close(ResortBar)
end

% for i=2 % 1:AmountOfSubScans
%     disp(['Working on SubScan s' num2str(i) ]);
%     % ResortBar = waitbar(0,['Resorting ' num2str((Data(i).NumDarks + Data(i).NumFlats + Data(i).NumProjections + Data(i).NumFlats)) ' projections for SubScan s' num2str(i)],'name','Please Wait...');
%     %% Resort Darks and Flats
%     % Pre-Projection
% %     disp(['Resorting Pre-Darks and Pre-Flats for SubScan ' num2str(i) ]);
% %     ResortBar = waitbar(0,['Resorting ' num2str((Data(i).NumDarks + Data(i).NumFlats)) ' Pre-Darks and -Flats of SubScan s' num2str(i)],'name','Please Wait...');
% %     for k=1:Data(i).NumDarks + Data(i).NumFlats
% %         OriginalFile = [Data(i).SampleFolder filesep 'tif' filesep Data(i).SubScanName num2str(sprintf('%04d',k)) '.tif' ];
% %         DestinationFile = [ OutputDirectory filesep OutPutTifDirName filesep MergedScanName num2str(sprintf(Decimal,(AmountOfSubScans*k)-(AmountOfSubScans-i))) '.tif' ];
% %         ResortCommand = [ do ' ' OriginalFile ' ' DestinationFile ];
% %         waitbar(k/(Data(i).NumDarks + Data(i).NumFlats));
% %         % disp(ResortCommand);
% %         [status,result] = system(ResortCommand);
% %     end % k=1:Darks+Flats
% %     close(ResortBar)
%     % Post-Projection
% %     disp(['Resorting Post-Flats for SubScan ' num2str(i) ])
% %     ResortBar = waitbar(0,['Resorting ' num2str(Data(i).NumFlats) ' Post-Flats of SubScan s' num2str(i)],'name','Please Wait...');
% %     for k=Data(i).ProjectionNumberLast:Data(i).ProjectionNumberLast + Data(i).NumFlats
% %         OriginalFile = [Data(i).SampleFolder filesep 'tif' filesep Data(i).SubScanName num2str(sprintf('%04d',k)) '.tif' ];
% %         DestinationFile = [ OutputDirectory filesep OutPutTifDirName filesep MergedScanName num2str(sprintf(Decimal,(AmountOfSubScans*k)-(AmountOfSubScans-i))) '.tif' ];
% %         ResortCommand = [ do ' ' OriginalFile ' ' DestinationFile ];
% %         waitbar(k/(Data(i).NumFlats));
% %         % disp(ResortCommand);
% %         [status,result] = system(ResortCommand);
% %     end % k=End of Projections to End of Files
% %     close(ResortBar)
%     %% Resort Projections
%     disp(['Resortign Projections for SubScan ' num2str(i) ]);
%         ResortBar = waitbar(0,['Resorting ' num2str(Data(i).ProjectionNumberLast) ' Projections of SubScan s' num2str(i)],'name','Please Wait...');
%     for k=Data(i).ProjectionNumberFirst:Data(i).ProjectionNumberLast
%         OriginalFile = [Data(i).SampleFolder filesep 'tif' filesep Data(i).SubScanName num2str(sprintf('%04d',k)) '.tif' ];
%         DestinationFile = [ OutputDirectory filesep OutPutTifDirName filesep MergedScanName num2str(sprintf(Decimal,((AmountOfSubScans*k)-(AmountOfSubScans-i)))) '.tif' ]; % NUmber outputfile according to Interpolation.
%         ResortCommand = [ do ' ' OriginalFile ' ' DestinationFile ];
%         waitbar(k/(Data(i).ProjectionNumberLast));
%         % disp(ResortCommand);
%         [status,result] = system(ResortCommand);        
%     end % k=Start:End of Projections
%     close(ResortBar)
% end % i=1:AmountOfSubScans
disp('Done with Resorting');
disp('---');

disp(['Generating logfile for ' MergedScanName ]);
LogFile = [ OutputDirectory filesep OutPutTifDirName filesep MergedScanName '.log' ];
dlmwrite(LogFile, ['User ID : ' Data(1).UserID],'delimiter','');
dlmwrite(LogFile, ['Merged Projections from ' num2str(AmountOfSubScans) ' SubScans to ' MergedScanName '. Log was generated on ' datestr(now) ],'-append','delimiter','');
dlmwrite(LogFile, '--------------------Beamline Settings-------------------------','-append','delimiter','');
dlmwrite(LogFile, ['Ring current [mA]            : ' num2str(mean([Data(1).RingCurrent Data(2).RingCurrent Data(3).RingCurrent])) ],'-append','delimiter','');
dlmwrite(LogFile, ['Beam energy  [keV]           : ' num2str(mean([Data(1).BeamEnergy Data(2).BeamEnergy Data(3).BeamEnergy])) ],'-append','delimiter','');
dlmwrite(LogFile, ['Monostripe                   : ' Data(1).Mono ],'-append','delimiter','');
dlmwrite(LogFile, '--------------------Detector Settings-------------------------','-append','delimiter','');
dlmwrite(LogFile, ['Objective                    : ' num2str(Data(1).Objective) ],'-append','delimiter','');
dlmwrite(LogFile, ['Scintillator                 : ' Data(1).Scintillator ],'-append','delimiter','');
dlmwrite(LogFile, ['Exposure time [ms]           : ' num2str(Data(1).ExposureTime) ],'-append','delimiter','');
dlmwrite(LogFile, '------------------------Scan Settings-------------------------','-append','delimiter','');
dlmwrite(LogFile, ['Sample folder                : ' OutputDirectory ],'-append','delimiter','');
dlmwrite(LogFile, ['File Prefix                  : ' MergedScanName ],'-append','delimiter','');
dlmwrite(LogFile, ['Amount of SubScans           : ' num2str(AmountOfSubScans) ],'-append','delimiter','');
for i=1:AmountOfSubScans % writing Cutlines to LogFile
    dlmwrite(LogFile, [ 'Number of projections for s' num2str(i) ' : ' num2str(Data(i).NumProjections) ],'-append','delimiter','');   
end
dlmwrite(LogFile, ['Number of darks              : ' num2str(Data(1).NumDarks + Data(2).NumDarks + Data(3).NumDarks) ],'-append','delimiter','');
dlmwrite(LogFile, ['Number of flats              : ' num2str(Data(1).NumFlats + Data(2).NumFlats + Data(3).NumFlats) ],'-append','delimiter','');   
dlmwrite(LogFile, ['Number of inter-flats        : ' num2str(Data(1).InterFlats) ],'-append','delimiter','');
dlmwrite(LogFile, ['Inner scan flag              : ' num2str(Data(1).InnerScan) ],'-append','delimiter','');
dlmwrite(LogFile, ['Flat frequency               : ' num2str(Data(1).FlatFreq) ],'-append','delimiter','');
dlmwrite(LogFile, ['Rot Y min position  [deg]    : ' num2str(Data(1).RotYmin) ],'-append','delimiter','');
dlmwrite(LogFile, ['Rot Y max position  [deg]    : ' num2str(Data(1).RotYmax) ],'-append','delimiter','');
dlmwrite(LogFile, ['Angular step [deg]           : ' num2str(Data(1).AngularStep) ],'-append','delimiter','');
dlmwrite(LogFile, ['Sample In   [um]             : ' num2str(Data(1).SampleIn) ],'-append','delimiter','');
dlmwrite(LogFile, ['Sample Out  [um]             : ' num2str(Data(1).SampleOut) ],'-append','delimiter','');
dlmwrite(LogFile, '--------------------------------------------------------------','-append','delimiter','');
for i=1:AmountOfSubScans-1 % writing Cutlines to LogFile
    dlmwrite(LogFile, [ 'Cutline between s' num2str(i) ' and s' num2str(i+1) '    : ' num2str(Data(i).Cutline) ' px' ],'-append','delimiter','');   
end
dlmwrite(LogFile, '--------------------------------------------------------------','-append','delimiter','');

%% Hardlink/Copy LogFile
if isunix
    what = 'Hardlink';
    do = 'ln';
else
    what = 'Copy';
    do = 'cp';
end
disp([ what 'ing Logfile' ]);
LogFileLinkCommand = [ do ' ' LogFile ' ' LogFilePath MergedScanName '.log' ];
system(LogFileLinkCommand);
disp('----');

%% Sinogram generation.
disp('Sinogram Generation');
SinogramCommand = ( [ 'sinooff_tomcat_j_widefieldscan.py ' OutputDirectory filesep OutPutTifDirName ]);
warndlg('Generating Sinograms. This takes at least 10 minutes and doesn`t give any feedback. Please be patient.', 'Sinogram Generation');
if isunix == 0
    disp(['I would now generate Sinograms for ' OutputDirectory ' with the command:']);
    disp([ '"' SinogramCommand '"' ]);
    disp('But since we are working on a windows machine, we are probably not at the Beamline...');
else
    disp(['Generating Sinograms for ' OutputDirectory ' with the command:']);
    disp([ '"' SinogramCommand '"' ]);
    disp('----');
    [ status, result] = system(SinogramCommand);
end

disp([ 'If you don`t see any sinograms in ' OutputDirectory filesep 'sin, please execute the following command on x02da-cons-2:']);
disp(' ')
disp(SinogramCommand)
disp(' ')
disp('to generate the Sinograms of the merged projections.');

disp('----');
disp('Been there, done that. Means; I am finished with everything you have asked me.');
disp([ 'The whole process took me around ' num2str(round(toc/60)) ' minutes' ]);