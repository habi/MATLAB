%% definition
%% mergeprojections
%% loads the images from the sub-projections from disk and concatenates
%% them into one big projection, so that we can then generate the sinograms
%% from the widefieldscan and reconstruct the big slices.

%% 11.09.2008 - initial version, cobbled together from widefieldscan.m and
%% concatenate_final.m, written during the last beamtime.
%% 18.09.2008 - images are now loaded correctly
%% 19.09.2008 - dark and flat field correction
%% 26.09.2008 - augfrund der grauwerte in den tiff-bildern auf writeDMP
%% ausgewichen, so werden die merged projections mit korrekten helligkeiten
%% auf die Platte geschrieben
%% 27.09.2008 - w�hrend des schreibens der DMPs werden die globalen
%% minimalen und maximalen Helligkeitswerte registriert und anschliessend
%% bei Bedarf zum umschreiben in .tifs gebraucht

%% init
clear;
clc;
close all;
warning off Images:initSize:adjustingMag % suppress the warning about big images, they are still displayed correctly, just a bit smaller..
tic;
disp(['It`s now ' datestr(now) ]);

%% run/file parameters
skipcount = 0;          % skip image counting for each subscan
skipcorrection = 0;     % skip dark and flat-field stuff
showdarksandflats = 0;  % show them or not
showplots = 0;          % show plot of NumProj and FactorToCenter
writeTif = 0;           % write result as .tiff
showTif = 0;            % show the merged projections as tiff
writeDMP = 1;           % write result as .DMP
showDMP = 0;            % show the merged projections as DMP
consecutiveTif = 0      % write Tifs as #1..2..3 instead of as #FromToTo

%% which case?
% whichcase = 2; %1=R108C60Brul-W_, 2=R108C04BrulW_
% if whichcase == 1
%     SampleBaseName = 'R108C04BrulW_'; %with PostFlats!
%     readpostflats = 1;
% elseif whichcase == 2
%     SampleBaseName = 'R108C60Brul-W_';
%     readpostflats = 0;
%     % warndlg('Did you change the overlap?','Overlap');
% end

% which sample?
SampleBaseName = 'R108C04C_';
readpostflats = 1;

%% setup
UserID = 'e11126';

AmountOfSubScans = 3

if isunix == 1 
    PathToFiles = '/Data10/2008b/';    
    whereamI = '/sls/X02DA/data/';
    BasePath = fullfile( whereamI , UserID , PathToFiles )
    addpath([ whereamI UserID '/MATLAB/SRuCT']) 
else
    whereamI = 'E:';
    PathToFiles = '/2008b/';
    BasePath = fullfile(whereamI, PathToFiles);   
    addpath('P:\MATLAB\SRuCT')
end

Magnification = 10;

GlobalMin = 0;
GlobalMax = 0;

InputDirectory = 'tif';
OutputDirectory = 'mrg';

NumFlats = 10;
NumDarks = 2;

if AmountOfSubScans == 3
    SubScanDetails(1) = struct('Name', 's1', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], 'FlatImg', [], ...
        'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
    SubScanDetails(2) = struct('Name', 's2', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], 'FlatImg', [], ...
        'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
    SubScanDetails(3) = struct('Name', 's3', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], 'FlatImg', [], ...
        'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
elseif AmountOfSubScans == 5
    SubScanDetails(1) = struct('Name', 's1', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], 'FlatImg', [], ...
        'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
    SubScanDetails(2) = struct('Name', 's2', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], 'FlatImg', [], ...
        'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
    SubScanDetails(3) = struct('Name', 's3', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], 'FlatImg', [], ...
        'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
    SubScanDetails(4) = struct('Name', 's4', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], 'FlatImg', [], ...
         'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
    SubScanDetails(5) = struct('Name', 's5', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], 'FlatImg', [], ...
         'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
end

% how many files are in the directories?
% maybe we could also read in the widefield-scan-preference-textfile, but I
% don't always have those handy...
if skipcount == 0
    disp('Im counting the filenumber for each SubScan...');
    for n = 1:length(SubScanDetails)
        CurrentDir = [ BasePath SampleBaseName SubScanDetails(n).Name '/' InputDirectory '/'];
        cd(CurrentDir);
        filelist = dir([fileparts(CurrentDir) filesep '*.tif']);
        SubScanDetails(n).NumProj = length({filelist.name});
        disp(['Subscan "' SubScanDetails(n).Name '" has ' num2str(SubScanDetails(n).NumProj) ' .tif-Files in its Directory']);
    end
    disp(['We acquired ' num2str(NumDarks) ' Darks and ' num2str(NumFlats) ' Flats for each SubScan, ...']);
    if readpostflats ==1
        disp('And we`ve acquired postflats')
    end
    for n = 1:length(SubScanDetails)
        SubScanDetails(n).NumProj = SubScanDetails(n).NumProj - NumDarks - NumFlats - NumFlats;
        disp(['So we acquired ' num2str(SubScanDetails(n).NumProj) ' Projections for Subscan "' SubScanDetails(n).Name '"']);
    end
else %skipcount
    disp('I`ve skipped counting the imagessome...')
end  %skipcount

%% Average Darks
if skipcorrection == 0
    disp('Working on the darks');
    for n = 1:length(SubScanDetails)
        disp(['Working on SubScan ' SampleBaseName SubScanDetails(n).Name]);
        for k = 1:NumDarks
            ReadPath = [ BasePath SampleBaseName SubScanDetails(n).Name '/' InputDirectory '/' ...
                SampleBaseName SubScanDetails(n).Name num2str(sprintf('%04d',k)) '.tif'];
            disp(['Loading Dark Image Nr. ' num2str(k)]);
            DarkImages(:,:,k) = imread([ReadPath]);
        end
        SubScanDetails(n).AvgDarks = mean(DarkImages,3);
        clear DarkImages;
    end

    %% Average Flats
    disp('Working on the flats');
    for n = 1:length(SubScanDetails)
        disp(['Working on SubScan ' SampleBaseName SubScanDetails(n).Name]);
        % preflats
        for k = 1:NumFlats
            ReadPath = [ BasePath SampleBaseName SubScanDetails(n).Name '/' InputDirectory '/' ...
                SampleBaseName SubScanDetails(n).Name num2str(sprintf('%04d',k+NumDarks)) '.tif'];
            disp(['Loading Preflat Image Nr. ' num2str(k) ]);
            FlatImages(:,:,k) = imread([ReadPath]);
        end
        % postflats
        if readpostflats == 1
            for k = 1:NumFlats
                postflatnumber=k+SubScanDetails(n).NumProj+NumDarks+NumFlats;
                ReadPath = [ BasePath SampleBaseName SubScanDetails(n).Name '/' InputDirectory '/' ...
                    SampleBaseName SubScanDetails(n).Name num2str(sprintf('%04d',postflatnumber)) '.tif'];
                disp(['Loading Postflat Image Nr. ' num2str(postflatnumber) ]);
                FlatImages(:,:,NumFlats+k) = imread([ReadPath]);
            end
        end
        SubScanDetails(n).AvgFlats = mean(FlatImages,3);
        clear FlatImages;
    end

    for n = 1:length(SubScanDetails)
        SubScanDetails(n).FlatImage = log(SubScanDetails(n).AvgFlats-SubScanDetails(n).AvgDarks);
        if showdarksandflats == 1
            figure
                subplot(131)
                    imshow(SubScanDetails(n).AvgDarks,[])
                    title(['Averaged Dark Image for Subscan ' SubScanDetails(n).Name])
                subplot(132)
                    imshow(SubScanDetails(n).AvgFlats,[])
                    title(['Averaged Flat Image for Subscan ' SubScanDetails(n).Name])
                subplot(133)
                    imshow(SubScanDetails(n).FlatImage,[])
                    title(['Averaged and Corrected Flat Image for Subscan ' SubScanDetails(n).Name])
        elseif showdarksandflats == 0
            disp('Darks and Flats are not shown')
        end % showdarksandflats
    end
else % skipcorrection
    disp('I`ve skipped the dark and flat stuff...')
end  %skipcount
   

%% Difference (Modulo) of NumProj-Ring to NumProjCenter is calculated, to
%% be able to use it for the interpolation afterwards
for n = 1:length(SubScanDetails)
    if AmountOfSubScans ==3
        SubScanDetails(n).ModuloToCenter = (SubScanDetails(2).NumProj/SubScanDetails(n).NumProj)/(SubScanDetails(2).NumProj/SubScanDetails(1).NumProj);
    elseif AmountOfSubScans == 5
        SubScanDetails(n).ModuloToCenter = (SubScanDetails(3).NumProj/SubScanDetails(n).NumProj)/(SubScanDetails(3).NumProj/SubScanDetails(1).NumProj);
    end
end

if showplots == 1
    NumProj=[SubScanDetails.NumProj];
    ModuloToCenter=[SubScanDetails.ModuloToCenter];
    figure
        subplot(121)
            plot([SubScanDetails.NumProj]);
            axis([0 length(SubScanDetails)+1 0 1.1*max([SubScanDetails.NumProj])]);
            title('NumProj');
        subplot(122)
            plot([SubScanDetails.ModuloToCenter]);
            axis([0 length(SubScanDetails)+1 0 1.1*max([SubScanDetails.ModuloToCenter])]);
            title('ModuloToCenter');
else
    disp('The plots are not shown')
end % showplots

%% loop over the images, calculate the cutline, save it for later and then
%% perform the Merging
FromToTo = 1:32:max([SubScanDetails.NumProj]); % go from zero to maximal amount of NumProj
for FileNumber = FromToTo
    for n=1:length(SubScanDetails)
        % read in files for concatenation
        ReadPath = [ BasePath SampleBaseName SubScanDetails(n).Name '/' InputDirectory '/' ...
            SampleBaseName SubScanDetails(n).Name num2str(sprintf('%04d',ceil((FileNumber/SubScanDetails(n).ModuloToCenter)+NumDarks+NumFlats))) ...
            '.tif'];
        SubScanDetails(n).CurrentProjection = imread(ReadPath);
        SubScanDetails(n).CurrentProjection = -log(double(SubScanDetails(n).CurrentProjection)./double(SubScanDetails(n).AvgFlats));
        SubScanDetails(n).GrayMin = min( min(min(SubScanDetails(n).CurrentProjection)), SubScanDetails(n).GrayMin);
        SubScanDetails(n).GrayMax = max( max(max(SubScanDetails(n).CurrentProjection)), SubScanDetails(n).GrayMax);
        % keep globally lowest and globally highest grayvalue for scaling
        % the tiffs at the end.
        GlobalMin = min(SubScanDetails(n).GrayMin,GlobalMin);
        GlobalMax = max(SubScanDetails(n).GrayMax,GlobalMax);
        % compute Cutline
        %%%% TEMPORARILY HARDCODED FOR 7.10.2008
%         if n > 1 && isinf(SubScanDetails(n-1).Cutline)
%             disp('Calculating cutline (this will take some time...)')
%             SubScanDetails(n-1).Cutline = function_cutline(SubScanDetails(n-1).CurrentProjection,SubScanDetails(n).CurrentProjection);
%         end
        SubScanDetails(1).Cutline = 70;
        SubScanDetails(2).Cutline = 65;
        SubScanDetails(3).Cutline = 61;
        SubScanDetails(4).Cutline = 68;
        % SubScanDetails(5).Cutline = Inf
        %% END HARDCODING
    end
    % merge the files to a big projection, depending on what the
    % cutline-function gives out in different sequences...
    if AmountOfSubScans ==3
     if SubScanDetails(1).Cutline < 0
            MergedProjection = [ ...
                SubScanDetails(3).CurrentProjection ...
                SubScanDetails(2).CurrentProjection(:,abs(SubScanDetails(2).Cutline) + 1:size(SubScanDetails(2).CurrentProjection,2)) ...
                SubScanDetails(1).CurrentProjection(:,abs(SubScanDetails(1).Cutline) + 1:size(SubScanDetails(1).CurrentProjection,2)) ...
                ];
        elseif SubScanDetails(1).Cutline == 0
            MergedProjection = [ ...
                SubScanDetails(1).CurrentProjection ...
                SubScanDetails(2).CurrentProjection ...
                SubScanDetails(3).CurrentProjection ...
                ];
        else
            MergedProjection = [ ...
                SubScanDetails(1).CurrentProjection ...
                SubScanDetails(2).CurrentProjection(:,SubScanDetails(1).Cutline + 1:size(SubScanDetails(2).CurrentProjection,2)) ...
                SubScanDetails(3).CurrentProjection(:,SubScanDetails(2).Cutline + 1:size(SubScanDetails(3).CurrentProjection,2)) ...
                ];
        end
    elseif AmountOfSubScans == 5
        if SubScanDetails(1).Cutline < 0
            MergedProjection = [ ...
                SubScanDetails(5).CurrentProjection ...
                SubScanDetails(4).CurrentProjection(:,abs(SubScanDetails(4).Cutline) + 1:size(SubScanDetails(4).CurrentProjection,2)) ...
                SubScanDetails(3).CurrentProjection(:,abs(SubScanDetails(3).Cutline) + 1:size(SubScanDetails(3).CurrentProjection,2)) ...
                SubScanDetails(2).CurrentProjection(:,abs(SubScanDetails(2).Cutline) + 1:size(SubScanDetails(2).CurrentProjection,2)) ...
                SubScanDetails(1).CurrentProjection(:,abs(SubScanDetails(1).Cutline) + 1:size(SubScanDetails(1).CurrentProjection,2)) ...
                ];
        elseif SubScanDetails(1).Cutline == 0
            MergedProjection = [ ...
                SubScanDetails(1).CurrentProjection ...
                SubScanDetails(2).CurrentProjection ...
                SubScanDetails(3).CurrentProjection ...
                SubScanDetails(4).CurrentProjection ...
                SubScanDetails(5).CurrentProjection ...
                ];
        else
            MergedProjection = [ ...
                SubScanDetails(1).CurrentProjection ...
                SubScanDetails(2).CurrentProjection(:,SubScanDetails(1).Cutline + 1:size(SubScanDetails(2).CurrentProjection,2)) ...
                SubScanDetails(3).CurrentProjection(:,SubScanDetails(2).Cutline + 1:size(SubScanDetails(3).CurrentProjection,2)) ...
                SubScanDetails(4).CurrentProjection(:,SubScanDetails(3).Cutline + 1:size(SubScanDetails(4).CurrentProjection,2)) ...
                SubScanDetails(5).CurrentProjection(:,SubScanDetails(4).Cutline + 1:size(SubScanDetails(5).CurrentProjection,2)) ...
                ];
        end
    end
    clear SubscanDetails(:).CurrentProjection
    
    %% Write the MergedProjection to Disk (as .DMP). We record the
    %% grayvalues of the Projections and write them to .tif afterwards...
    WriteDir = [ BasePath 'mrg/' SampleBaseName OutputDirectory ];
    [success,message,messageID] = mkdir(WriteDir);
    if writeDMP == 1
        disp(['writing DMP #' num2str(FileNumber) ' to disk'])
        [success,message,messageID] = mkdir([ WriteDir '/DMP/' ]);
        WriteDMPName = [WriteDir '/DMP/' SampleBaseName OutputDirectory '-' num2str(sprintf('%04d',FileNumber)) ];
        writeDumpImage(MergedProjection,[WriteDMPName '.DMP']);
        if showDMP == 1
            figure
                imshow(readDumpImage([WriteDMPName '.DMP']),[])
                %displayDumpImage(readDumpImage([WriteDMPName '.DMP']));
                pause(0.01)
                close
        end % showDMP
        clear MergedProjection;
    else % writeDMP
        disp('I`m not writing a .DMP and thus won`t show it...')
    end % writeDMP
end % FileNumberLoop

%% use GlobalMin and GlobalMax to write out .tiffs with correct brightness.
if writeTif == 1
if writeDMP == 1
    Number = 1;
    for FileNumber = FromToTo
        TifFileNumber = FileNumber;
        if consecutiveTif == 1
            TifFileNumber = Number;
            Number = Number +1;
        end
        disp(['Converting DMP #' num2str(FileNumber) ' to .tif'])
        % read .DMP
        ReadDir = [ BasePath 'mrg/' SampleBaseName OutputDirectory ];
        ReadDMPName = [ReadDir '/DMP/' SampleBaseName OutputDirectory '-' num2str(sprintf('%04d',FileNumber)) ];
        % read image and scale to GlobalMax/GlobalMin
        DMP = readDumpImage([ReadDMPName '.DMP']);
        DMP = DMP - GlobalMin;
        DMP = DMP ./ GlobalMax;
        % write .tif
        [success,message,messageID] = mkdir([ WriteDir '/tif/' ]);
        WriteTifName = [ ReadDir '/tif/' SampleBaseName OutputDirectory ...
            num2str(sprintf('%04d',TifFileNumber)) ];
        imwrite(DMP,[WriteTifName '.tif'],'Compression','none');  % Compression none, so that ImageJ can read the tiff-files...
        if showTif ==1
            figure('name','.tif')
                imshow(DMP,[]);
               %pause(.25)
                close
        end % showtif
        clear DMP;
    end % FileNumberLoop
elseif writeDMP == 0
    disp('There where no DMPs written, so I cannot convert them to .tif')
end % writeDMP catcher
else % writeTif
    disp('I`m not writing a .tiff and thus won`t show it...')
end % writeTif
disp( ['I`ve written ' num2str(TifFileNumber) ' tiffs > logfile...']);

%%%%%%%%%%%%%%%%%
% generate fake LogFile
%%%%%%%%%%%%%%%%%

% NumDarks = 0;
% NumFlats = 0;
% inputDirsuffix = SubScanDetails(1).Name
% outputDirsuffix = 'mrg';
% readDir = '/tif/';
% writeDir = '';
% filesuffix = '.log';
% 
% ReadSampleName = [ SampleBaseName inputDirsuffix]
% inputfile = [ BasePath ReadSampleName readDir ReadSampleName filesuffix ]
% 
% WriteSampleName = [ SampleBaseName outputDirsuffix]
% outputpath = [ BasePath 'mrg/' WriteSampleName  ]
% [success,message,messageID] = mkdir([outputpath '/tif/' ]);
% outputfile = [ outputpath '/tif/' WriteSampleName filesuffix ]
% 
% disp(['Im counting the filenumber of the tiffs in the /mrg-Directory of ' WriteSampleName '...']);
% 
% cd([outputpath '/tif/']);
% filelist = dir([fileparts([outputpath '/tif/']) filesep '*.tif']);
% NumProj = length({filelist.name});
% disp(['We`ve got ' num2str(NumProj) ' merged Projections.']);
%     
% %% write the stuff to a faked log-file.    
% % User ID : e11126
% dlmwrite(outputfile, ['User ID : ' UserID],'delimiter','');
% % FAST-TOMO scan of sample R108C60c_s1 started on Mon Oct 06 18:51:01 2008 
% dlmwrite(outputfile, ['FAST-TOMO scan of sample ' WriteSampleName '. Log was faked on ' datestr(now) ],'-append','delimiter','');
% % --------------------Beamline Settings-------------------------
% dlmwrite(outputfile, ['--------------------Beamline Settings-------------------------'],'-append','delimiter','');
% % Ring current [mA]           : 400.650 
% dlmwrite(outputfile, ['Ring current [mA]           : 400.650'],'-append','delimiter','');
% % Beam energy  [keV]          : 15.072 
% dlmwrite(outputfile, ['Beam energy  [keV]          : 15.072'],'-append','delimiter','');
% % Monostripe                  : Ru/C 
% dlmwrite(outputfile, ['Monostripe                  : Ru/C'],'-append','delimiter','');
% % --------------------Detector Settings-------------------------
% dlmwrite(outputfile, ['--------------------Detector Settings-------------------------'],'-append','delimiter','');
% % Objective                   : 10.00 
% dlmwrite(outputfile, ['Objective                   : ' num2str(sprintf('%.2f',Magnification)) ],'-append','delimiter','');
% % Scintillator                : YAG:Ce 18 um 
% dlmwrite(outputfile, ['Scintillator                : YAG:Ce 18 um'],'-append','delimiter','');
% % Exposure time [ms]          : 500 
% dlmwrite(outputfile, ['Exposure time [ms]          : 500'],'-append','delimiter','');
% % ------------------------Scan Settings-------------------------
% dlmwrite(outputfile, ['------------------------Scan Settings-------------------------'],'-append','delimiter','');
% % Sample folder                : /sls/X02DA/data/e11126/Data10/2008b/R108C60c_s1 
% dlmwrite(outputfile, ['Sample folder                : ' outputpath ],'-append','delimiter','');
% % File Prefix                  : R108C60c_s1 
% dlmwrite(outputfile, ['File Prefix                  : ' WriteSampleName ],'-append','delimiter','');
% % Number of projections        : 4676 
% dlmwrite(outputfile, ['Number of projections        : ' num2str(NumProj) ],'-append','delimiter','');
% % Number of darks              : 2 
% dlmwrite(outputfile, ['Number of darks              : ' num2str(NumDarks) ],'-append','delimiter','');
% % Number of flats              : 10 
% dlmwrite(outputfile, ['Number of flats              : ' num2str(NumFlats) ],'-append','delimiter','');
% % Number of inter-flats        : 0 
% dlmwrite(outputfile, ['Number of inter-flats        : 0'],'-append','delimiter','');
% % Inner scan flag              : 0 
% dlmwrite(outputfile, ['Inner scan flag              : 0'],'-append','delimiter','');
% % Flat frequency               : 0 
% dlmwrite(outputfile, ['Flat frequency               : 0'],'-append','delimiter','');
% % Rot Y min position  [deg]    : 45.000 
% dlmwrite(outputfile, ['Rot Y min position  [deg]    : 45.000'],'-append','delimiter','');
% % Rot Y max position  [deg]    : 225.000 
% dlmwrite(outputfile, ['Rot Y max position  [deg]    : 225.000'],'-append','delimiter','');
% % Angular step [deg]           : 0.039 
% dlmwrite(outputfile, ['Angular step [deg]           : 0.039'],'-append','delimiter','');
% % Sample In   [um]             : -1442 
% dlmwrite(outputfile, ['Sample In   [um]             : -1442'],'-append','delimiter','');
% % Sample Out  [um]             : 10000 
% dlmwrite(outputfile, ['Sample Out  [um]             : 10000'],'-append','delimiter','');
% % --------------------------------------------------------------
% dlmwrite(outputfile, ['--------------------------------------------------------------'],'-append','delimiter','');
% % Start logging activity...
% dlmwrite(outputfile, ['Start logging activity...'],'-append','delimiter','');% Start logging activity...
% dlmwrite(outputfile, ['It`s a fake log-file, believe me!'],'-append','delimiter','');
% dlmwrite(outputfile, ['But the stuff below might be of value again...'],'-append','delimiter','');

%%%%%%%%%%%%%%%%%
% finish
%%%%%%%%%%%%%%%%%

disp('I`m done with all you`ve asked for...')
disp(['It`s now ' datestr(now) ]);
zyt=toc;
disp(['It took me ' num2str(zyt/60) ' minutes to perform this task' ]);
helpdlg('I`m done with all you`ve asked for...','Phew!');