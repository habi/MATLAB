function fct_mergeSubScan(SampleName,FirstSubScanNumber,AmountOfSubScans,NumDarks,NumFlats,Tiff,OutputSampleName,OutputSuffix)

skip=0; % skip some unnecessary stuff, mainly for testing
WriteEveryXth = 1;

    tic; disp(['It`s now ' datestr(now) ]);
    warning off Images:initSize:adjustingMag % suppress the warning about big images, they are still displayed correctly, just a bit smaller..
   
    UserID = 'e11126';
    Magnification = '10';
    currentLocation = pwd; % since we're 'cd'ing around, save the current location to go back to it at the end
    if isunix == 1 
        %beamline
        %whereamI = '/sls/X02DA/data';
        %slslc05
        whereamI = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da';
        PathToFiles = '/Data10/2009a';    
        SamplePath = fullfile( whereamI , UserID , PathToFiles );
        addpath([ whereamI filesep UserID filesep 'MATLAB'])
        addpath([ whereamI filesep UserID filesep 'MATLAB' filesep 'SRuCT']) 
    else
        whereamI = 'E:';
        PathToFiles = '/2009a';
        SamplePath = fullfile(whereamI, PathToFiles);   
        addpath('P:\MATLAB')
        addpath('P:\MATLAB\SRuCT')
    end
    
    if Tiff == 1
        OutputFormat = 'tiff';
    else
        OutputFormat = 'DMP';
    end

    LastSubScanNumber = ( FirstSubScanNumber + AmountOfSubScans - 1 );
    
    disp('---');
    disp([ 'merging ' SamplePath SampleName ' with ' num2str(AmountOfSubScans) ...
        ' SubScans from s' num2str(FirstSubScanNumber) ' to s' ...
        num2str(LastSubScanNumber) ]);
    disp('---');
    %% Counting Files (since logfileparsing is too complicated for me...)
    disp([ 'counting Files for each SubScan of ' SampleName ]);         
    for CurrentSubScan = 1:AmountOfSubScans
        CurrentSubScanNumber = num2str((FirstSubScanNumber + CurrentSubScan - 1 ));
        SubScanDetails(CurrentSubScan).Name = [ SampleName '_s' CurrentSubScanNumber ];
        CurrentTifDir = [ SamplePath filesep SubScanDetails(CurrentSubScan).Name filesep 'tif' filesep ];
        cd(CurrentTifDir);
        filelist = dir([fileparts(CurrentTifDir) filesep '*.tif']);
        SubScanDetails(CurrentSubScan).NumProj = length({filelist.name});
        disp([ SubScanDetails(CurrentSubScan).Name '/tif contains ' num2str(SubScanDetails(CurrentSubScan).NumProj) ' tiff-Files']);
        SubScanDetails(CurrentSubScan).NumProj = SubScanDetails(CurrentSubScan).NumProj - NumDarks - NumFlats - NumFlats; % Darks, Pre- and PostFlats
    end
    disp(['We acquired ' num2str(NumDarks) ' Darks and ' num2str(NumFlats) ' Flats.']);
    for CurrentSubScan = 1:AmountOfSubScans
        disp(['So we acquired ' num2str(SubScanDetails(CurrentSubScan).NumProj) ' Projections for Subscan "' SubScanDetails(CurrentSubScan).Name '"']);
    end

    %% Difference (Modulo) of NumProj-Ring to NumProjCenter is calculated, to
    %% be able to use it for the interpolation afterwards
    for CurrentSubScan = 1:AmountOfSubScans
        if AmountOfSubScans ==3
            SubScanDetails(CurrentSubScan).ModuloToCenter = (SubScanDetails(2).NumProj/SubScanDetails(CurrentSubScan).NumProj)/(SubScanDetails(2).NumProj/SubScanDetails(1).NumProj);
        elseif AmountOfSubScans == 5
            SubScanDetails(CurrentSubScan).ModuloToCenter = (SubScanDetails(3).NumProj/SubScanDetails(CurrentSubScan).NumProj)/(SubScanDetails(3).NumProj/SubScanDetails(1).NumProj);         
        end
        disp(['The ratio of acquired Projections for Subscan ' SubScanDetails(CurrentSubScan).Name ...
            ' compared to the central SubScan is 1:' num2str(SubScanDetails(CurrentSubScan).ModuloToCenter) ]);
    end
    
if skip ~= 1    
    %% Average Darks
    for CurrentSubScan = 1:AmountOfSubScans
        disp(['Averaging Darks for ' SubScanDetails(CurrentSubScan).Name ]);
        for k = 1:NumDarks
            CurrentTifDir = [ SamplePath filesep SubScanDetails(CurrentSubScan).Name filesep 'tif' filesep ];
            DarkFile = [ CurrentTifDir SubScanDetails(CurrentSubScan).Name num2str(sprintf('%04d',k)) '.tif'];
            % disp(['Loading Dark Image Nr. ' num2str(k)]);
            DarkImages(:,:,k) = imread([DarkFile]);
        end
        SubScanDetails(CurrentSubScan).AverageDark = mean(DarkImages,3);
        clear DarkImages;
%         figure;imshow(SubScanDetails(CurrentSubScan).AverageDark,[]);title(['Average Dark for ' SubScanDetails(CurrentSubScan).Name ])
    end
end % if skip

if skip ~= 1
    %% Average Flats
    for CurrentSubScan = 1:AmountOfSubScans
        disp(['Averaging Flats for ' SubScanDetails(CurrentSubScan).Name ]);
        for k = 1:NumFlats
            CurrentTifDir = [ SamplePath filesep SubScanDetails(CurrentSubScan).Name filesep 'tif' filesep ];
            % disp(['Loading Flat Image Nr. ' num2str(k) ' (preflat)' ]);
            FlatFile = [ CurrentTifDir SubScanDetails(CurrentSubScan).Name num2str(sprintf('%04d',k)) '.tif'];
            FlatImages(:,:,k) = imread([FlatFile]);
            % disp(['Loading Flat Image Nr. ' num2str(k) ' (postflat)' ]);
            FlatFile = [ CurrentTifDir SubScanDetails(CurrentSubScan).Name num2str(sprintf('%04d',k+SubScanDetails(CurrentSubScan).NumProj+NumDarks+NumFlats)) '.tif'];
            FlatImages(:,:,k+NumFlats) = imread([FlatFile]);
        end
        SubScanDetails(CurrentSubScan).AverageFlat = mean(FlatImages,3);
        clear FlatImages;
%         figure;imshow(SubScanDetails(CurrentSubScan).AverageFlat,[]);title(['Average Flat for ' SubScanDetails(CurrentSubScan).Name ],'Interpreter','None')
    end
end % if skip
    
    %% load a subset of the images for the calculation of GlobalMin & GlobalMax
    GrayValueLoadHowMany = 100;
    GlobalMin = 0;
    GlobalMax = 0;
    disp(['I`m randomly loading ' num2str(AmountOfSubScans * GrayValueLoadHowMany) ...
        ' tiffs from all SubScans of ' SampleName ' to look for the minimal and maximal Grayvalue' ]);
    for CurrentSubScan=1:AmountOfSubScans
        SubScanDetails(CurrentSubScan).GrayMin = 0;
        SubScanDetails(CurrentSubScan).GrayMax = 0;
        disp(['Searching for minimal and maximal Grayvalue in ' num2str(GrayValueLoadHowMany) ...
            ' Projections from ' SubScanDetails(CurrentSubScan).Name ]);
        w = waitbar(0,['Looking for minimal and maximal Grayvalue in SubScan ' num2str(CurrentSubScan) ]);
        for HM = 1:GrayValueLoadHowMany
            FileNumber = round(rand * SubScanDetails(CurrentSubScan).NumProj);
            waitbar(HM/GrayValueLoadHowMany);
            % read in files for concatenation
            CurrentTifDir = [ SamplePath filesep SubScanDetails(CurrentSubScan).Name filesep 'tif' filesep ];
            % disp(['Reading File ' num2str(ceil((FileNumber/SubScanDetails(CurrentSubScan).ModuloToCenter)+NumDarks+NumFlats)) ]);
            FileToRead = [ CurrentTifDir filesep SubScanDetails(CurrentSubScan).Name ...
                num2str(sprintf('%04d',ceil((FileNumber/SubScanDetails(CurrentSubScan).ModuloToCenter)+NumDarks+NumFlats))) ...
                '.tif'];
            TmpImage = imread(FileToRead);
            if skip ~= 1
                TmpImage = -log(double(TmpImage)./double(SubScanDetails(CurrentSubScan).AverageFlat));
            end 
%             figure;imshow(TmpImage,[]);pause(0.05);close;
            SubScanDetails(CurrentSubScan).GrayMin = min( min(min(TmpImage)), SubScanDetails(CurrentSubScan).GrayMin);
            SubScanDetails(CurrentSubScan).GrayMax = max( max(max(TmpImage)), SubScanDetails(CurrentSubScan).GrayMax);
            % keep globally lowest and globally highest grayvalue for scaling
            % the tiffs at the end.
            GlobalMin = min(SubScanDetails(CurrentSubScan).GrayMin,GlobalMin);
            GlobalMax = max(SubScanDetails(CurrentSubScan).GrayMax,GlobalMax);
        end
        close(w);
        pause(0.001);
    end

    clear TmpImage;
    GlobalMin = GlobalMin - ( .25 * GlobalMin ); % set 25% lower for safety reasons
    GlobalMax = GlobalMax + ( .25 * GlobalMax ); % set 25% higher for safety reasons
    % disp(['The global minimal grayvalue is ' num2str(GlobalMin) ','])
    % disp(['the global maximal grayvalue is ' num2str(GlobalMax) '.']);

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
        % = ProjectionImage @ 180�
    else
        CutlineGenerationFileNumber = NumDarks + NumFlats + 1;
        % = 1. Projection Image
    end
	for CurrentSubScan=1:AmountOfSubScans
        SubScanDetails(CurrentSubScan).Cutline = Inf;
        % read in files for concatenation
        CurrentTifDir = [ SamplePath filesep SubScanDetails(CurrentSubScan).Name filesep 'tif' filesep ];
        CutFile = [ CurrentTifDir SubScanDetails(CurrentSubScan).Name ...
            num2str(sprintf('%04d',ceil(( CutlineGenerationFileNumber/SubScanDetails(CurrentSubScan).ModuloToCenter) + NumDarks + NumFlats )))...
            '.tif'];
        SubScanDetails(CurrentSubScan).CurrentProjection = imread(CutFile);
        SubScanDetails(CurrentSubScan).CurrentProjection = -log(double(SubScanDetails(CurrentSubScan).CurrentProjection)./double(SubScanDetails(CurrentSubScan).AverageFlat));
        % compute Cutline
        if CurrentSubScan > 1 && isinf(SubScanDetails(CurrentSubScan-1).Cutline)
            disp(['Calculating cutline between ' SubScanDetails(CurrentSubScan-1).Name ' and ' SubScanDetails(CurrentSubScan).Name ' (this will take some time...)']);
            SubScanDetails(CurrentSubScan-1).Cutline = function_cutline(SubScanDetails(CurrentSubScan-1).CurrentProjection,SubScanDetails(CurrentSubScan).CurrentProjection);
            disp(['The cutline between ' SubScanDetails(CurrentSubScan-1).Name ' and ' SubScanDetails(CurrentSubScan).Name ' is ' num2str(SubScanDetails(CurrentSubScan-1).Cutline) 'px.']);           
        end
%         SubScanDetails(1).Cutline = 90;
%         SubScanDetails(2).Cutline = 90;
%         SubScanDetails(3).Cutline = 61;
%         SubScanDetails(4).Cutline = 68;
%         SubScanDetails(5).Cutline = Inf
    end
    
    
    %% Merge Files
    FromToTo = 1:WriteEveryXth:max([SubScanDetails.NumProj]); % go from zero to maximal amount of NumProj
    w = waitbar(0,['Writing ' num2str(length(FromToTo)) ' merged Projections of ' SampleName '-' OutputSuffix '-mrg to Disk.' ]);
    if Tiff == 1
        disp(['Writing ' num2str(length(FromToTo)) ' merged Projections of ' SampleName '-' OutputSuffix '-mrg as .tif.'])
    elseif Tiff == 0
        disp(['Writing ' num2str(length(FromToTo)) ' merged Projections of ' SampleName '-' OutputSuffix '-mrg as .DMP.'])
    end % writeDMP
    for FileNumber = FromToTo
        waitbar(FileNumber/max(FromToTo));
        for CurrentSubScan=1:AmountOfSubScans
            % read in files for concatenation
            CurrentTifDir = [ SamplePath filesep SubScanDetails(CurrentSubScan).Name filesep 'tif' filesep ];
            FileToMerge = [ CurrentTifDir SubScanDetails(CurrentSubScan).Name ...
                num2str(sprintf('%04d',ceil(( FileNumber/SubScanDetails(CurrentSubScan).ModuloToCenter) + NumDarks + NumFlats ))) ...
                '.tif'];
            SubScanDetails(CurrentSubScan).CurrentProjection = imread(FileToMerge);
            if skip ~= 1
                SubScanDetails(CurrentSubScan).CurrentProjection = -log(double(SubScanDetails(CurrentSubScan).CurrentProjection)./double(SubScanDetails(CurrentSubScan).AverageFlat));
            end % ifskip
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
        
        if ~isempty(OutputSampleName) % if User Specified a new name to save under, use this one from now on...
            SampleName = OutputSampleName;
        end
        
        % Write Tiffs
        if Tiff == 1
            % mkdir for merged Proj
            WriteDir = [ SamplePath filesep 'mrg' filesep SampleName '-' OutputSuffix '-mrg' filesep 'tif' ];
            [success,message,messageID] = mkdir(WriteDir);
            % disp(['writing ' SampleName '-' OutputSuffix '-mrg' num2str(sprintf('%04d',FileNumber)) '.tif to disk'])
            WriteTifName = [ WriteDir filesep SampleName '-' OutputSuffix '-mrg' num2str(sprintf('%04d',FileNumber)) ];
            MergedProjection = MergedProjection - GlobalMin;
            MergedProjection = MergedProjection ./ GlobalMax;
            % write .tif
            imwrite(MergedProjection,[ WriteTifName '.tif' ],'Compression','none');  % Compression none, so that ImageJ can read the tiff-files...
        end % writeTif
        % write DMPs
        if Tiff == 0
            % mkdir for merged Proj
            WriteDir = [ SamplePath filesep 'mrg' filesep SampleName '-' OutputSuffix '-mrg' filesep 'DMP' ];
            [success,message,messageID] = mkdir(WriteDir);
            % disp(['writing ' SampleName '-' OutputSuffix '-mrg' num2str(sprintf('%04d',FileNumber)) '.DMP to disk'])
            WriteDMPName = [ WriteDir filesep SampleName '-' OutputSuffix '-mrg' num2str(sprintf('%04d',FileNumber)) ];
            writeDumpImage(MergedProjection,[WriteDMPName '.DMP']);
        end % writeDMP
        
        clear MergedProjection;
        
    end % FileNumberLoop
    close(w);
    %%%%%%%%%%%%%%%%%
    % generate fake LogFile
    %%%%%%%%%%%%%%%%%
   
    LogFileName = [ SampleName '-' OutputSuffix '-mrg.log' ];
    LogFile = [ WriteDir filesep LogFileName ]; % WriteDir is used from above, so we have different paths depending on tif/DMP.
    WriteSampleName = [ SampleName '-' OutputSuffix '-mrg' ];
    
    disp(['Generating fake logfile for the sample ' WriteSampleName '.' ]);

    %% write the stuff to a faked log-file.    
    % User ID : e11126
    dlmwrite(LogFile, ['User ID : ' UserID],'delimiter','');
    % FAST-TOMO scan of sample R108C60c_s1 started on Mon Oct 06 18:51:01 2008 
    dlmwrite(LogFile, ['Merged Scan of sample ' WriteSampleName ' generated from ' num2str(AmountOfSubScans) ' SubScans. Log was faked on ' datestr(now) ],'-append','delimiter','');
    % --------------------Beamline Settings-------------------------
    dlmwrite(LogFile, ['--------------------Beamline Settings-------------------------'],'-append','delimiter','');
    % Ring current [mA]           : 400.650 
    dlmwrite(LogFile, ['Ring current [mA]           : 400'],'-append','delimiter','');
    % Beam energy  [keV]          : 15.072 
    dlmwrite(LogFile, ['Beam energy  [keV]          : 12.600'],'-append','delimiter','');
    % Monostripe                  : Ru/C 
    dlmwrite(LogFile, ['Monostripe                  : Ru/C'],'-append','delimiter','');
    % --------------------Detector Settings-------------------------
    dlmwrite(LogFile, ['--------------------Detector Settings-------------------------'],'-append','delimiter','');
    % Objective                   : 10.00 
    dlmwrite(LogFile, ['Objective                   : ' num2str(sprintf('%.2f',Magnification)) ],'-append','delimiter','');
    % Scintillator                : YAG:Ce 18 um 
    dlmwrite(LogFile, ['Scintillator                : YAG:Ce 18 um'],'-append','delimiter','');
    % Exposure time [ms]          : 500 
    dlmwrite(LogFile, ['Exposure time [ms]          : (see original Logfile of ' SubScanDetails(1).Name ')' ],'-append','delimiter','');
    % ------------------------Scan Settings-------------------------
    dlmwrite(LogFile, ['------------------------Scan Settings-------------------------'],'-append','delimiter','');
    % Sample folder                : /sls/X02DA/data/e11126/Data10/2008b/R108C60c_s1 
    dlmwrite(LogFile, ['Sample folder                : ' WriteDir ],'-append','delimiter','');
    % File Prefix                  : R108C60c_s1 
    dlmwrite(LogFile, ['File Prefix                  : ' WriteSampleName ],'-append','delimiter','');
    % Number of projections        : 4676 
    dlmwrite(LogFile, ['Number of projections        : ' num2str(SubScanDetails(1).NumProj) ],'-append','delimiter','');
    % Number of darks              : 2 
    dlmwrite(LogFile, ['Number of darks              : 0'],'-append','delimiter','');%since we don't have any...
    % Number of flats              : 10 
    dlmwrite(LogFile, ['Number of flats              : 0'],'-append','delimiter','');
    % Number of inter-flats        : 0 
    dlmwrite(LogFile, ['Number of inter-flats        : 0'],'-append','delimiter','');
    % Inner scan flag              : 0 
    dlmwrite(LogFile, ['Inner scan flag              : 0'],'-append','delimiter','');
    % Flat frequency               : 0 
    dlmwrite(LogFile, ['Flat frequency               : 0'],'-append','delimiter','');
    % Rot Y min position  [deg]    : 45.000 
    dlmwrite(LogFile, ['Rot Y min position  [deg]    : (see original Logfile of ' SubScanDetails(1).Name ')' ],'-append','delimiter','');
    % Rot Y max position  [deg]    : 225.000 
    dlmwrite(LogFile, ['Rot Y max position  [deg]    : (see original Logfile of ' SubScanDetails(1).Name ')' ],'-append','delimiter','');
    % Angular step [deg]           : 0.039 
    dlmwrite(LogFile, ['Angular step [deg]           : (see original Logfile of ' SubScanDetails(1).Name ')' ],'-append','delimiter','');
    % Sample In   [um]             : -1442 
    dlmwrite(LogFile, ['Sample In   [um]             : (see original Logfile of ' SubScanDetails(1).Name ')' ],'-append','delimiter','');
    % Sample Out  [um]             : 10000 
    dlmwrite(LogFile, ['Sample Out  [um]             : (see original Logfile of ' SubScanDetails(1).Name ')' ],'-append','delimiter','');
    % --------------------------------------------------------------
    dlmwrite(LogFile, ['--------------------------------------------------------------'],'-append','delimiter','');
    % Start logging activity...
    dlmwrite(LogFile, ['Start logging activity...'],'-append','delimiter','');% Start logging activity...
    dlmwrite(LogFile, ['It`s a fake log-file, believe me!'],'-append','delimiter','');
    dlmwrite(LogFile, ['But the stuff below might be of value again...'],'-append','delimiter','');
    dlmwrite(LogFile, ['--------------------------------------------------------------'],'-append','delimiter','');
    dlmwrite(LogFile, ['Cutline between SubScan 1 and 2: ' num2str(SubScanDetails(1).Cutline) ' pixels' ],'-append','delimiter','');% Start logging activity...
    dlmwrite(LogFile, ['Cutline between SubScan 2 and 3: ' num2str(SubScanDetails(2).Cutline) ' pixels' ],'-append','delimiter','');% Start logging activity...
    if AmountOfSubScans == 5
        dlmwrite(LogFile, ['Cutline between SubScan 3 and 4: ' num2str(SubScanDetails(3).Cutline) ' pixels'],'-append','delimiter','');
        dlmwrite(LogFile, ['Cutline between SubScan 4 and 5: ' num2str(SubScanDetails(4).Cutline) ' pixels'],'-append','delimiter','');
    end
    dlmwrite(LogFile, ['--------------------------------------------------------------'],'-append','delimiter','');

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
            num2str(round(sekunde/10)*10) ' seconds to merge the sample ' ...
            SampleName '-' OutputSuffix '-mrg' ]);
    end    
	disp('---');
    
    %% generate sinograms
    command = [ /work/sls/bin/sinooff_tomcat_j.py /afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data10/2009b/mrg/R108C36B-A-mrg/tif]

    command = ['prj2sin ' savedir '/tif' addtosavedir '/' Filename '_conc####.tif -g 0 -f '...
       num2str(((ProtocolNumProjRing(whichone)-1)/2)+1) ',0,0,0,0 -d -j ' num2str(255) ' -r 0,0,0,0 -o ' ...
       savedir '/sin' addtosavedir '/' ]
    system(command);
    
cd(currentLocation);
end
