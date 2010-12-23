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

%% init
clear;
clc;
close all;
warning off Images:initSize:adjustingMag % suppress the warning about big images, they are still displayed correctly, just a bit smaller..
  
%% run/file parameters
skipcount = 0;          % skip image counting for each subscan
skipcorrection = 0;     % skip dark and flat-field stuff
showdarksandflats = 0;  % show them or not
showplots = 1;          % show plot of NumProj and FactorToCenter
writeTif = 1;           % write result as .tiff
showTif = 0;            % show the merged projections as tiff
writeDMP = 1;           % write result as .DMP
showDMP = 0;            % show the merged projections as tiff

%% which case?
whichcase = 1; %1=R108C60Brul-W_, 2=R108C04BrulW_
if whichcase == 1
    SampleBaseName = 'R108C04BrulW_'; %with PostFlats!
    readpostflats = 1;
elseif whichcase == 2
    SampleBaseName = 'R108C60Brul-W_';
    readpostflats = 0;
end

%% setup
BasePath = 'E:/SLS_2008a/';

SubScanDetails(1) = struct('Name', 's1', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], 'FlatImg', [], ...
    'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [1] );
SubScanDetails(2) = struct('Name', 's2', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], 'FlatImg', [], ...
    'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [1] );
SubScanDetails(3) = struct('Name', 's3', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], 'FlatImg', [], ...
    'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [1] );
SubScanDetails(4) = struct('Name', 's4', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], 'FlatImg', [], ...
    'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [1] );
SubScanDetails(5) = struct('Name', 's5', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], 'FlatImg', [], ...
    'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [1] );

GlobalMin = 0;
GlobalMax = 0;

InputDirectory = 'tif';
OutputDirectory = 'mrg';

NumDarks = 5;
NumFlats = 5;

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
    SubScanDetails(n).ModuloToCenter = (SubScanDetails(3).NumProj/SubScanDetails(n).NumProj)/(SubScanDetails(3).NumProj/SubScanDetails(1).NumProj);
end

if showplots == 1
    NumProj=[SubScanDetails.NumProj]
    ModuloToCenter=[SubScanDetails.ModuloToCenter]
    figure
        subplot(121)
            plot([SubScanDetails.NumProj])
            axis([0 length(SubScanDetails)+1 0 1.1*max([SubScanDetails.NumProj])])
            title('NumProj')
        subplot(122)
            plot([SubScanDetails.ModuloToCenter])
            axis([0 length(SubScanDetails)+1 0 1.1*max([SubScanDetails.ModuloToCenter])])
            title('ModuloToCenter')
else
    disp('The plots are not shown')
end % showplots

%% which images?
FromToTo = [1:16:max([SubScanDetails.NumProj]-NumFlats)]; % go from zero to maximal amount of NumProj
for FileNumber = FromToTo
    for n=1:length(SubScanDetails)
        ReadPath = [ BasePath SampleBaseName SubScanDetails(n).Name '/' InputDirectory '/' ...
            SampleBaseName SubScanDetails(n).Name num2str(sprintf('%04d',ceil((FileNumber/SubScanDetails(n).ModuloToCenter)+NumDarks+NumFlats))) ...
            '.tif'];
        SubScanDetails(n).CurrentProjection = imread(ReadPath);
        SubScanDetails(n).CurrentProjection = -log(double(SubScanDetails(n).CurrentProjection)./double(SubScanDetails(n).AvgFlats));
        SubScanDetails(n).GrayMin = min( min(min(SubScanDetails(n).CurrentProjection)), SubScanDetails(n).GrayMin);
        SubScanDetails(n).GrayMax = max( max(max(SubScanDetails(n).CurrentProjection)), SubScanDetails(n).GrayMax);
        GlobalMin = min(SubScanDetails(n).GrayMin,GlobalMin);
        GlobalMax = max(SubScanDetails(n).GrayMax,GlobalMax);
        SubScanDetails(n).Cutline = floor(size(SubScanDetails(n).CurrentProjection,2)*0.15);
    end
    
    MergedProjection = [ ...
        SubScanDetails(1).CurrentProjection(:,1:size(SubScanDetails(1).CurrentProjection,2)-SubScanDetails(1).Cutline) ...
        SubScanDetails(2).CurrentProjection(:,1:size(SubScanDetails(2).CurrentProjection,2)-SubScanDetails(2).Cutline) ...
        SubScanDetails(3).CurrentProjection ...
        SubScanDetails(4).CurrentProjection(:,SubScanDetails(4).Cutline:1024) ...
        SubScanDetails(5).CurrentProjection(:,SubScanDetails(5).Cutline:1024) ];

    %% Write the MergedProjection to Disk (as .DMP). We record the
    %% grayvalues of the Projections and write them to .tif afterwards...
    WriteDir = [ BasePath SampleBaseName OutputDirectory ];
    [success,message,messageID] = mkdir(WriteDir);
    if writeDMP == 1
        disp(['writing DMP #' num2str(FileNumber) ' to disk'])
        addpath('P:\MATLAB\SRuCT')
        [success,message,messageID] = mkdir([ WriteDir '/DMP/' ]);
        WriteDMPName = [WriteDir '/DMP/' SampleBaseName OutputDirectory '-' num2str(sprintf('%04d',FileNumber)) ];
        writeDumpImage(MergedProjection,[WriteDMPName '.DMP']);
        if showDMP == 1
            figure
                imshow(readDumpImage([WriteDMPName '.DMP']),[])
%             displayDumpImage(readDumpImage([WriteDMPName '.DMP']));
        end % showDMP
        clear MergedProjection;
    else % writeDMP
        disp('I`m not writing a .DMP and thus won`t show it...')
    end % writeDMP
end % FileNumberLoop

%% use GlobalMin and GlobalMax to write out .tiffs with correct brightness.
if writeTif == 1
if writeDMP == 1
    for FileNumber = FromToTo
        disp(['Converting DMP #' num2str(FileNumber) ' to .tif'])
        % read .DMP
        ReadDir = [ BasePath SampleBaseName OutputDirectory ];
        ReadDMPName = [ReadDir '/DMP/' SampleBaseName OutputDirectory '-' num2str(sprintf('%04d',FileNumber)) ];
        % read image and scale to GlobalMax/GlobalMin
        DMP = readDumpImage([ReadDMPName '.DMP']);
        DMP = DMP - GlobalMin;
        DMP = DMP ./ GlobalMax;
        % write .tif
        [success,message,messageID] = mkdir([ WriteDir '/tif/' ]);
        WriteTifName = [ ReadDir '/tif/' SampleBaseName OutputDirectory '-' ...
            num2str(sprintf('%04d',FileNumber)) ];
        imwrite(DMP,[WriteTifName '.tiff'],'Compression','none');  % Compression none, so that ImageJ can read the tiff-files...
        if showTif ==1
            figure
                imshow(MergedProjection);
        end % showtif
        clear DMP;
    end % FileNumberLoop
elseif writeDMP == 0
    disp('There where no DMPs written, so I cannot convert them to .tif')
end % writeDMP catcher
else % writeTif
    disp('I`m not writing a .tiff and thus won`t show it...')
end % writeTif

%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%

disp('I`m done with all you`ve asked for...')
helpdlg('I`m done with all you`ve asked for...','Phew!');