%% definition
%% mergeprojections
%% loads the images from the sub-projections from disk and concatenates
%% them into one big projection, so that we can then generate the sinograms
%% from the widefieldscan and reconstruct the big slices.

%% 11.09.2008 - initial version, cobbled together from widefieldscan.m and
%%      concatenate_final.m, written during the last beamtime.
%% 18.09.2008 - images are now loaded correctly
%% 19.09.2008 - dark and flat field correction
%% 26.09.2008 - augfgrund der grauwerte in den tiff-bildern auf writeDMP
%%      ausgewichen, so werden die merged projections mit korrekten helligkeiten
%%      auf die Platte geschrieben
%% 27.09.2008 - wührend des schreibens der DMPs werden die globalen
%%      minimalen und maximalen Helligkeitswerte registriert und anschliessend
%%      bei Bedarf zum umschreiben in .tifs gebraucht
%%      Messung 2008b: Anpassung an Unix/Windows > so müssen nicht mehr jedesmal
%%      alle Pfade umgeschrieben werden.
%% 26.11.2008: Nach Messung 2008c auf den neuesten Stand angepasst.
%%      MergeProjections kann jetzt über mehrere Protokolle im selben
%%      Unterordner loopen, so dass viele verschiedene Protokolle des
%%      selben Samples gemergt werden künnen. Grauwerte werden nun global
%%      über alle Protokolle berechnet, indem ein Anteil der Bilder geladen
%%      wird, und so das globale Minimum und Maximum berechnet wird. Bei
%%      Durchlauf über Protokolle wird dann das Minimum des aktuellen und
%%      globalen Minimums als neues Minimum gesetzt (analog für Max..)

%% init
clear;
close all;
clc;
warning off Images:initSize:adjustingMag % suppress the warning about big ...
    % images, they are still displayed correctly, just a bit smaller..
tic; disp(['It`s now ' datestr(now) ]);

%% run/file parameters
writeTif = 1;   % write result as .tiff
writeDMP = 0;   % write result as .DMP

% which sample?
SamplePrefixName = 'R108C21C';
Suffixes = ['b';'c';'d';'e';'f';'g';'h';'i';'j';'k';'l';'m';'n';'o';'p';'q';'r';'s';'t'];

% for Logfile @ the end and other stuff
AmountOfSubScans = 3;
NumDarks = 5;
NumFlats = 20;
readpostflats = 1;
Magnification = 10;
GlobalMin = 0;GlobalMax = GlobalMin;
GrayValueLoadHowMany = 100;         % load this many for subscan to calculate grayvalues
WriteEveryXth = 500;                % write every Xth file to disk
%% setup
UserID = 'e11126';

if isunix == 1 
    %beamline
    %whereamI = '/sls/X02DA/data/';
    %slslc05
    whereamI = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/';
    PathToFiles = '/Data10/2008c/';    
    BasePath = fullfile( whereamI , UserID , PathToFiles );
    addpath([ whereamI UserID '/MATLAB'])
    addpath([ whereamI UserID '/MATLAB/SRuCT']) 
else
    whereamI = 'E:';
    PathToFiles = '/2008c/';
    BasePath = fullfile(whereamI, PathToFiles);   
    addpath('P:\MATLAB')
    addpath('P:\MATLAB\SRuCT')
end

InputDirectory = 'tif';
OutputDirectory = 'mrg';

for WhichSample = 1:length(Suffixes)
    
    SampleBaseName = [SamplePrefixName Suffixes(WhichSample,:) '_' ];
    disp(['Working on Sample ' num2str(SampleBaseName) ]);

    if AmountOfSubScans == 3
        SubScanDetails(1) = struct('Name', 's1', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], ...
            'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
        SubScanDetails(2) = struct('Name', 's2', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], ...
            'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
        SubScanDetails(3) = struct('Name', 's3', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], ...
            'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
    elseif AmountOfSubScans == 5
        SubScanDetails(1) = struct('Name', 's1', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], ...
            'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
        SubScanDetails(2) = struct('Name', 's2', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], ...
            'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
        SubScanDetails(3) = struct('Name', 's3', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], ...
            'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
        SubScanDetails(4) = struct('Name', 's4', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], ...
             'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
        SubScanDetails(5) = struct('Name', 's5', 'NumProj', [], 'AvgDarks', [], 'AvgFlats', [], ...
             'ModuloToCenter', [], 'CurrentProjection', [], 'GrayMin', [0], 'GrayMax', [0], 'Cutline', [ Inf ] );
    end

    % how many files are in the directories?
    % maybe we could also read in the widefield-scan-preference-textfile, but I
    % don't always have those handy...
    disp('Im counting the filenumber for each SubScan...');
    for n = 1:length(SubScanDetails)
        CurrentDir = [ BasePath SampleBaseName SubScanDetails(n).Name '/' InputDirectory '/'];
        cd(CurrentDir);
        filelist = dir([fileparts(CurrentDir) filesep '*.tif']);
        SubScanDetails(n).NumProj = length({filelist.name});
        disp([ SampleBaseName SubScanDetails(n).Name ' has ' num2str(SubScanDetails(n).NumProj) ' .tif-Files in its Directory']);
    end
    disp(['We acquired ' num2str(NumDarks) ' Darks and ' num2str(NumFlats) ' Flats for each SubScan, ...']);
    if readpostflats ==1
        disp('And we`ve acquired postflats')
    end
    for n = 1:length(SubScanDetails)
        SubScanDetails(n).NumProj = SubScanDetails(n).NumProj - NumDarks - NumFlats - NumFlats;
        disp(['So we acquired ' num2str(SubScanDetails(n).NumProj) ' Projections for Subscan "' SubScanDetails(n).Name '"']);
    end

    %% Average Darks
    disp('Working on the darks');
    for n = 1:length(SubScanDetails)
        disp(['Working on ' SampleBaseName SubScanDetails(n).Name]);
        for k = 1:NumDarks
            ReadPath = [ BasePath SampleBaseName SubScanDetails(n).Name '/' InputDirectory '/' ...
                SampleBaseName SubScanDetails(n).Name num2str(sprintf('%04d',k)) '.tif'];
%             disp(['Loading Dark Image Nr. ' num2str(k)]);
            DarkImages(:,:,k) = imread([ReadPath]);
        end
        SubScanDetails(n).AvgDarks = mean(DarkImages,3);
        clear DarkImages;
    end

    %% Average Flats
    disp('Working on the flats');
    for n = 1:length(SubScanDetails)
        disp(['Working on ' SampleBaseName SubScanDetails(n).Name]);
        % preflats
        for k = 1:NumFlats
            ReadPath = [ BasePath SampleBaseName SubScanDetails(n).Name '/' InputDirectory '/' ...
                SampleBaseName SubScanDetails(n).Name num2str(sprintf('%04d',k+NumDarks)) '.tif'];
%             disp(['Loading Preflat Image Nr. ' num2str(k) ]);
            FlatImages(:,:,k) = imread([ReadPath]);
        end
        % postflats
        if readpostflats == 1
            for k = 1:NumFlats
                postflatnumber=k+SubScanDetails(n).NumProj+NumDarks+NumFlats;
                ReadPath = [ BasePath SampleBaseName SubScanDetails(n).Name '/' InputDirectory '/' ...
                    SampleBaseName SubScanDetails(n).Name num2str(sprintf('%04d',postflatnumber)) '.tif'];
%                 disp(['Loading Postflat Image Nr. ' num2str(postflatnumber) ]);
                FlatImages(:,:,NumFlats+k) = imread([ReadPath]);
            end
        end
        SubScanDetails(n).AvgFlats = mean(FlatImages,3);
        clear FlatImages;
    end

    %% Difference (Modulo) of NumProj-Ring to NumProjCenter is calculated, to
    %% be able to use it for the interpolation afterwards
    for n = 1:length(SubScanDetails)
        if AmountOfSubScans ==3
            SubScanDetails(n).ModuloToCenter = (SubScanDetails(2).NumProj/SubScanDetails(n).NumProj)/(SubScanDetails(2).NumProj/SubScanDetails(1).NumProj);
        elseif AmountOfSubScans == 5
            SubScanDetails(n).ModuloToCenter = (SubScanDetails(3).NumProj/SubScanDetails(n).NumProj)/(SubScanDetails(3).NumProj/SubScanDetails(1).NumProj);
        end
    end

    %% load a subset of the images for the calculation of GlobalMin & GlobalMax
    if GlobalMin == 0 % calculate greyvalues at first run
        for n=1:length(SubScanDetails)
            disp(['Looking for minimal and maximal Grayvalue in ' SampleBaseName SubScanDetails(n).Name])
            w = waitbar(0,['Looking for minimal and maximal Grayvalue in SubScan ' num2str(n)]);
            for HM = 1:GrayValueLoadHowMany
                FileNumber = round(rand * SubScanDetails(n).NumProj);
%               clc;
%                disp(['working on subscan nr.' num2str(n)])
%                disp(['working on file #' num2str(sprintf('%04d',HM)) '/' num2str(GrayValueLoadHowMany) ...
%                   ' (' num2str(sprintf('%04d',FileNumber)) ') for the calculation' ...
%                      ' of GlobalMin & GlobalMax'])
                waitbar(HM/GrayValueLoadHowMany)
                % read in files for concatenation
                ReadPath = [ BasePath SampleBaseName SubScanDetails(n).Name '/' InputDirectory '/' ...
                    SampleBaseName SubScanDetails(n).Name num2str(sprintf('%04d',ceil((FileNumber/SubScanDetails(n).ModuloToCenter)+NumDarks+NumFlats))) ...
                    '.tif'];
                TmpImage = imread(ReadPath);
                TmpImage = -log(double(TmpImage)./double(SubScanDetails(n).AvgFlats));
                SubScanDetails(n).GrayMin = min( min(min(TmpImage)), SubScanDetails(n).GrayMin);
                SubScanDetails(n).GrayMax = max( max(max(TmpImage)), SubScanDetails(n).GrayMax);
                % keep globally lowest and globally highest grayvalue for scaling
                % the tiffs at the end.
                GlobalMin = min(SubScanDetails(n).GrayMin,GlobalMin);
                GlobalMax = max(SubScanDetails(n).GrayMax,GlobalMax);
            end
            close(w)
        end
        clear TmpImage;
        GlobalMin = GlobalMin - ( .25 * GlobalMin ); % set 25% lower for safety reasons
        GlobalMax = GlobalMax + ( .25 * GlobalMax ); % set 25% higher for safety reasons
    end
    disp(['The global minimal grayvalue is ' num2str(GlobalMin) ','])
    disp(['the global maximal grayvalue is ' num2str(GlobalMax) '.']);

%% loop over the images, calculate the cutline, save it for later and then
%% perform the Merging
    %% Cutline Extraction
    %% Sample Orientation is crucial for Cutline Extraction, or else the
    %% cutline algorithm cannot calculate the cutline...
        %% set file-number medium if sample is oriented in direction of the beam
        %% at the start of the scan
        %% set file-number low if sample is perpendicular to beam at the start
        %% of the scan
    perpendicular = 0;
    if perpendicular == 0
        CutlineGenerationFileNumber = max(SubScanDetails(1).NumProj) / 2 + NumDarks + NumFlats + 1;
        % using NumProj from 1. SubScan, thus assuming this is the one with
        % the most projections...
        % = ProjectionImage @ 180ü
    else
        CutlineGenerationFileNumber = NumDarks + NumFlats + 1;
        % = 1. Projection Image
    end
    for n=1:length(SubScanDetails)
        % read in files for concatenation
        ReadPath = [ BasePath SampleBaseName SubScanDetails(n).Name '/' InputDirectory '/' ...
            SampleBaseName SubScanDetails(n).Name num2str(sprintf('%04d',ceil((CutlineGenerationFileNumber/SubScanDetails(n).ModuloToCenter)+NumDarks+NumFlats)))...
            '.tif'];
        SubScanDetails(n).CurrentProjection = imread(ReadPath);
        SubScanDetails(n).CurrentProjection = -log(double(SubScanDetails(n).CurrentProjection)./double(SubScanDetails(n).AvgFlats));
        % compute Cutline
        if n > 1 && isinf(SubScanDetails(n-1).Cutline)
            disp(['Calculating cutline between Subscan ' num2str(n-1) ' and ' num2str(n) ' (this will take some time...)'])
            SubScanDetails(n-1).Cutline = function_cutline(SubScanDetails(n-1).CurrentProjection,SubScanDetails(n).CurrentProjection);
        end
%         SubScanDetails(1).Cutline = 150;
%         SubScanDetails(2).Cutline = 150;
%         SubScanDetails(3).Cutline = 61;
%         SubScanDetails(4).Cutline = 68;
%         SubScanDetails(5).Cutline = Inf
    end
    %% Merge Files
    FromToTo = 1:WriteEveryXth:max([SubScanDetails.NumProj]); % go from zero to maximal amount of NumProj
    for FileNumber = FromToTo
        for n=1:length(SubScanDetails)
            % read in files for concatenation
            ReadPath = [ BasePath SampleBaseName SubScanDetails(n).Name '/' InputDirectory '/' ...
                SampleBaseName SubScanDetails(n).Name num2str(sprintf('%04d',ceil((FileNumber/SubScanDetails(n).ModuloToCenter)+NumDarks+NumFlats))) ...
                '.tif'];
            SubScanDetails(n).CurrentProjection = imread(ReadPath);
            SubScanDetails(n).CurrentProjection = -log(double(SubScanDetails(n).CurrentProjection)./double(SubScanDetails(n).AvgFlats));
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

        %% Write the MergedProjection to Disk (either as Tiff or as .DMP). 
        %% We record the grayvalues of the Projections and write them to .tif afterwards...

        % mkdir for merged Proj
        WriteDir = [ BasePath 'mrg/' SampleBaseName OutputDirectory ];
        [success,message,messageID] = mkdir(WriteDir);
        % write DMPs
        if writeDMP == 1
            disp(['writing ' num2str(SampleBaseName) num2str(OutputDirectory) num2str(sprintf('%04d',FileNumber)) '.DMP to disk'])
            [success,message,messageID] = mkdir([ WriteDir '/DMP/' ]);
            WriteDMPName = [WriteDir '/DMP/' SampleBaseName OutputDirectory '-' num2str(sprintf('%04d',FileNumber)) ];
            writeDumpImage(MergedProjection,[WriteDMPName '.DMP']);
        end % writeDMP
        % Write Tiffs
        if writeTif == 1
            disp(['writing ' num2str(SampleBaseName) num2str(OutputDirectory) num2str(sprintf('%04d',FileNumber)) '.tif to disk'])
            [success,message,messageID] = mkdir([ WriteDir '/tif/' ]);
            WriteTifName = [WriteDir '/tif/' SampleBaseName OutputDirectory num2str(sprintf('%04d',FileNumber)) ];
            MergedProjection = MergedProjection - GlobalMin;
            MergedProjection = MergedProjection ./ GlobalMax;
            % write .tif
            [success,message,messageID] = mkdir([ WriteDir '/tif/' ]);
            imwrite(MergedProjection,[WriteTifName '.tif'],'Compression','none');  % Compression none, so that ImageJ can read the tiff-files...
        end % writeTif

        clear MergedProjection;

    end % FileNumberLoop

    %%%%%%%%%%%%%%%%%
    % generate fake LogFile
    %%%%%%%%%%%%%%%%%

    outputDirsuffix = 'mrg';
    writeDir = '';
    filesuffix = '.log';

    WriteSampleName = [ SampleBaseName outputDirsuffix];
    outputpath = [ BasePath 'mrg/' WriteSampleName  ];
    [success,message,messageID] = mkdir([outputpath '/tif/' ]);
    outputfile = [ outputpath '/tif/' WriteSampleName filesuffix ];

    disp(['Im counting the filenumber of the tiffs in the /mrg-Directory of ' WriteSampleName '...']);

    cd([outputpath '/tif/']);
    filelist = dir([fileparts([outputpath '/tif/']) filesep '*.tif']);
    NumProj = length({filelist.name});
    disp(['We`ve got ' num2str(NumProj) ' merged Projections.']);

    %% write the stuff to a faked log-file.    
    % User ID : e11126
    dlmwrite(outputfile, ['User ID : ' UserID],'delimiter','');
    % FAST-TOMO scan of sample R108C60c_s1 started on Mon Oct 06 18:51:01 2008 
    dlmwrite(outputfile, ['FAST-TOMO scan of sample ' WriteSampleName '. Log was faked on ' datestr(now) ],'-append','delimiter','');
    % --------------------Beamline Settings-------------------------
    dlmwrite(outputfile, ['--------------------Beamline Settings-------------------------'],'-append','delimiter','');
    % Ring current [mA]           : 400.650 
    dlmwrite(outputfile, ['Ring current [mA]           : 400'],'-append','delimiter','');
    % Beam energy  [keV]          : 15.072 
    dlmwrite(outputfile, ['Beam energy  [keV]          : 12.600'],'-append','delimiter','');
    % Monostripe                  : Ru/C 
    dlmwrite(outputfile, ['Monostripe                  : Ru/C'],'-append','delimiter','');
    % --------------------Detector Settings-------------------------
    dlmwrite(outputfile, ['--------------------Detector Settings-------------------------'],'-append','delimiter','');
    % Objective                   : 10.00 
    dlmwrite(outputfile, ['Objective                   : ' num2str(sprintf('%.2f',Magnification)) ],'-append','delimiter','');
    % Scintillator                : YAG:Ce 18 um 
    dlmwrite(outputfile, ['Scintillator                : YAG:Ce 18 um'],'-append','delimiter','');
    % Exposure time [ms]          : 500 
    dlmwrite(outputfile, ['Exposure time [ms]          : 175'],'-append','delimiter','');
    % ------------------------Scan Settings-------------------------
    dlmwrite(outputfile, ['------------------------Scan Settings-------------------------'],'-append','delimiter','');
    % Sample folder                : /sls/X02DA/data/e11126/Data10/2008b/R108C60c_s1 
    dlmwrite(outputfile, ['Sample folder                : ' outputpath ],'-append','delimiter','');
    % File Prefix                  : R108C60c_s1 
    dlmwrite(outputfile, ['File Prefix                  : ' WriteSampleName ],'-append','delimiter','');
    % Number of projections        : 4676 
    dlmwrite(outputfile, ['Number of projections        : ' num2str(NumProj) ],'-append','delimiter','');
    % Number of darks              : 2 
    dlmwrite(outputfile, ['Number of darks              : 0'],'-append','delimiter','');%since we don't have any...
    % Number of flats              : 10 
    dlmwrite(outputfile, ['Number of flats              : 0'],'-append','delimiter','');
    % Number of inter-flats        : 0 
    dlmwrite(outputfile, ['Number of inter-flats        : 0'],'-append','delimiter','');
    % Inner scan flag              : 0 
    dlmwrite(outputfile, ['Inner scan flag              : 0'],'-append','delimiter','');
    % Flat frequency               : 0 
    dlmwrite(outputfile, ['Flat frequency               : 0'],'-append','delimiter','');
    % Rot Y min position  [deg]    : 45.000 
    dlmwrite(outputfile, ['Rot Y min position  [deg]    : 45.000'],'-append','delimiter','');
    % Rot Y max position  [deg]    : 225.000 
    dlmwrite(outputfile, ['Rot Y max position  [deg]    : 225.000'],'-append','delimiter','');
    % Angular step [deg]           : 0.039 
    dlmwrite(outputfile, ['Angular step [deg]           : 0.041'],'-append','delimiter','');
    % Sample In   [um]             : -1442 
    dlmwrite(outputfile, ['Sample In   [um]             : -1294'],'-append','delimiter','');
    % Sample Out  [um]             : 10000 
    dlmwrite(outputfile, ['Sample Out  [um]             : 10000'],'-append','delimiter','');
    % --------------------------------------------------------------
    dlmwrite(outputfile, ['--------------------------------------------------------------'],'-append','delimiter','');
    % Start logging activity...
    dlmwrite(outputfile, ['Start logging activity...'],'-append','delimiter','');% Start logging activity...
    dlmwrite(outputfile, ['It`s a fake log-file, believe me!'],'-append','delimiter','');
    dlmwrite(outputfile, ['But the stuff below might be of value again...'],'-append','delimiter','');
    dlmwrite(outputfile, ['--------------------------------------------------------------'],'-append','delimiter','');
    dlmwrite(outputfile, ['Cutline between SubScan 1 and 2: ' num2str(SubScanDetails(1).Cutline) ' pixels' ],'-append','delimiter','');% Start logging activity...
    dlmwrite(outputfile, ['Cutline between SubScan 2 and 3: ' num2str(SubScanDetails(2).Cutline) ' pixels' ],'-append','delimiter','');% Start logging activity...
    if AmountOfSubScans == 5
        dlmwrite(outputfile, ['Cutline between SubScan 3 and 4: ' num2str(SubScanDetails(3).Cutline) ' pixels'],'-append','delimiter','');
        dlmwrite(outputfile, ['Cutline between SubScan 4 and 5: ' num2str(SubScanDetails(4).Cutline) ' pixels'],'-append','delimiter','');
    end
    dlmwrite(outputfile, ['--------------------------------------------------------------'],'-append','delimiter','');
    %%%%%%%%%%%%%%%%%
    % finish
    %%%%%%%%%%%%%%%%%
    disp(['I`m done with the Sample ' num2str(WriteSampleName) ]);
    disp('---')
    disp('---')
    disp('---')
    disp('proceeding with the next one')
    disp('---')
    disp('---')
    disp('---')
    clear SubScanDetails;
end

%% finish
disp('I`m done with all you`ve asked for...')
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
%helpdlg('I`m done with all you`ve asked for...','Phew!');