function fct_mergeSubScanInterpolatedSelector(AmountOfSubScans,NumDarks,NumFlats,Tiff,BeamTime,OutputSampleName,OutputSuffix)

showProcess = 0; 

WriteEveryXth = 1;

    tic; disp(['It`s now ' datestr(now) ]);
    warning off Images:initSize:adjustingMag % suppress the warning about big images, they are still displayed correctly, just a bit smaller..
   
    UserID = 'e11126';
    Magnification = '10';
    currentLocation = pwd; % since we're 'cd'ing around, save the current location to go back to it at the end
    Cutlines = [];
    
    if isunix == 1 
        %beamline
            whereamI = '/sls/X02DA/data';
        %slslc05
            %whereamI = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da';
        PathToFiles = [ 'Data10' filesep BeamTime];    
        SamplePath = fullfile( whereamI , UserID , 'Data10', BeamTime );
        WritePath = fullfile( whereamI , UserID , 'Data3', BeamTime );
        addpath([ whereamI filesep UserID filesep 'MATLAB'])
        addpath([ whereamI filesep UserID filesep 'MATLAB' filesep 'WideFieldScan']) 
        addpath([ whereamI filesep UserID filesep 'MATLAB' filesep 'SRuCT']) 
    else
        whereamI = 'S:';
        PathToFiles = [ 'SLS' filesep BeamTime ];
        %%%%%% FOR TESTING %%%%%% 
%             whereamI = 'P:';
%             PathToFiles = [ '#Images' filesep 'MergeProjectionsTest' filesep ];
%             Cutlines = 0;
        %%%%%% FOR TESTING %%%%%% 
        SamplePath = fullfile(whereamI, PathToFiles);
        addpath('P:\MATLAB')
        addpath('P:\MATLAB\WideFieldScan')
        addpath('P:\MATLAB\SRuCT')
    end
    
    h=helpdlg(['I will now prompt you to select ' num2str(AmountOfSubScans) ...
        ' Directories for the SubScans which should be merged into one' ...
        ' Scan called "' OutputSampleName OutputSuffix '_mrg". You only' ...
        ' need to select the root-directory of each SubScan, i`ll look for' ...
        ' the "tif" directory inside myself...' ],'Instructions');
    uiwait(h);
    pause(0.01);
    
    % Let the user choose the correct location of the subscans, for each of
    % the subscans. Afterwards we extract the SubScanName with
    % fileparts(Location), since we use it for the generation of the path
    % and filenames for the flats, darks and projections.
    for CurrentSubScan = 1:AmountOfSubScans
        SubScanDetails(CurrentSubScan).Location = uigetdir(SamplePath,...
            [ 'Please locate SubScan Nr. ' num2str(CurrentSubScan) ' of ' ...
            num2str(AmountOfSubScans) ' to be merged into ' OutputSampleName ...
            OutputSuffix '_mrg' ]);
        [ tmp,SubScanDetails(CurrentSubScan).SubScanName,tmp ] = ...
            fileparts(SubScanDetails(CurrentSubScan).Location);
    end
       
    for CurrentSubScan = 1:AmountOfSubScans
        disp([ 'Subscan ' SubScanDetails(CurrentSubScan).SubScanName ' ('...
            num2str(CurrentSubScan) '/' num2str(AmountOfSubScans) ...
            ') is located at ' SubScanDetails(CurrentSubScan).Location ]);
    end
    
    if Tiff == 1
        OutputFormat = 'tiff';
    else
        OutputFormat = 'DMP';
    end
    
    disp('----');
    pause(1)
    
    %% Counting Files (KISS, since logfileparsing is too complicated for the moment...)
    for CurrentSubScan = 1:AmountOfSubScans
        disp([ 'counting tif-Files for ' SubScanDetails(CurrentSubScan).SubScanName ]);         
        CurrentTifDir = [ SubScanDetails(CurrentSubScan).Location filesep 'tif' filesep ];
        cd(CurrentTifDir);
        filelist = dir([fileparts(CurrentTifDir) filesep '*.tif']);
        SubScanDetails(CurrentSubScan).NumProj = length({filelist.name});
        disp([ SubScanDetails(CurrentSubScan).Location filesep 'tif contains ' num2str(SubScanDetails(CurrentSubScan).NumProj) ' tiff-Files']);
        SubScanDetails(CurrentSubScan).NumProj = SubScanDetails(CurrentSubScan).NumProj - NumDarks - NumFlats - NumFlats; % Darks, Pre- and PostFlats
    end

    disp(['We acquired ' num2str(NumDarks) ' Darks and ' num2str(NumFlats) ' Flats.']);
    for CurrentSubScan = 1:AmountOfSubScans
        disp(['So we acquired ' num2str(SubScanDetails(CurrentSubScan).NumProj) ...
            ' Projections for Subscan "' SubScanDetails(CurrentSubScan).SubScanName '"']);
    end

    %% Difference (Modulo) of NumProj-Ring to NumProjCenter is calculated, to
    %% be able to use it for the interpolation afterwards
    for CurrentSubScan = 1:AmountOfSubScans
        if AmountOfSubScans ==3
            SubScanDetails(CurrentSubScan).ModuloToCenter = (SubScanDetails(2).NumProj ...
                / SubScanDetails(CurrentSubScan).NumProj) / (SubScanDetails(2).NumProj ...
                / SubScanDetails(1).NumProj );
        elseif AmountOfSubScans == 5
            SubScanDetails(CurrentSubScan).ModuloToCenter = (SubScanDetails(3).NumProj ...
                / SubScanDetails(CurrentSubScan).NumProj) / (SubScanDetails(3).NumProj ...
                / SubScanDetails(1).NumProj);         
        end
        disp(['The ratio of acquired Projections for Subscan ' SubScanDetails(CurrentSubScan).SubScanName ...
            ' compared to the central SubScan is 1:' num2str(SubScanDetails(CurrentSubScan).ModuloToCenter) ]);
    end
    pause(0.01)
    disp('---');
    
    %% Average Darks
    for CurrentSubScan = 1:AmountOfSubScans
        disp([ 'Averaging ' num2str(NumDarks) ' Darks for ' ...
            SubScanDetails(CurrentSubScan).SubScanName ]);
        CurrentTifDir = [ SubScanDetails(CurrentSubScan).Location filesep 'tif' filesep ];
        for k = 1:NumDarks
            DarkFile = [ CurrentTifDir SubScanDetails(CurrentSubScan).SubScanName num2str(sprintf('%04d',k)) '.tif'];
            % disp(['Loading Dark Image Nr. ' num2str(k) ' of ' num2str(NumDarks) ]);
            DarkImages(:,:,k) = imread([DarkFile]);
        end
        if NumDarks ~= 0 % if we don't have any dark images as input, then we don't need to average them...
            SubScanDetails(CurrentSubScan).AverageDark = mean(DarkImages,3);
        end
        clear DarkImages;
        if showProcess == 1
            figure;
                imshow(SubScanDetails(CurrentSubScan).AverageDark,[]);
                title(['Average Dark for ' SubScanDetails(CurrentSubScan).SubScanName ], ...
                    'Interpreter','None') % Interpreter','None' prevents ...
                    % interpretations of Underscores and LaTeX-formatting of title
        end
    end

    %% Average Flats
    for CurrentSubScan = 1:AmountOfSubScans
        disp(['Averaging ' num2str(NumFlats) ' Flats for ' ...
            SubScanDetails(CurrentSubScan).SubScanName ]);
        CurrentTifDir = [ SubScanDetails(CurrentSubScan).Location filesep 'tif' filesep ];
        for k = 1:NumFlats
            % disp(['Loading Flat Image Nr. ' num2str(k) ' (preflat)' ]);
            FlatFile = [ CurrentTifDir SubScanDetails(CurrentSubScan).SubScanName num2str(sprintf('%04d',k)) '.tif'];
            FlatImages(:,:,k) = imread([FlatFile]);
            % disp(['Loading Flat Image Nr. ' num2str(k) ' (postflat)' ]);
            FlatFile = [ CurrentTifDir SubScanDetails(CurrentSubScan).SubScanName ... 
                num2str(sprintf('%04d',k+SubScanDetails(CurrentSubScan).NumProj+NumDarks+NumFlats)) '.tif'];
            FlatImages(:,:,k+NumFlats) = imread([FlatFile]);
        end
        if NumFlats ~= 0 % if there are no Flats to read, we don't need to average them
            SubScanDetails(CurrentSubScan).AverageFlat = mean(FlatImages,3);
        end
        clear FlatImages;
        if showProcess == 1
            figure;
            imshow(SubScanDetails(CurrentSubScan).AverageFlat,[]);
            title(['Average Flat for ' SubScanDetails(CurrentSubScan).SubScanName ], ...
                 'Interpreter','None') % Interpreter','None' prevents ...
                % interpretations of Underscores and LaTeX-formatting of title
        end
    end
    pause(0.001)
    disp('---');
    
    % load a subset of the images for the calculation of GlobalMin
    % afterwards ask the user if he/she likes these values and proceed.
    GrayValueLoadHowMany = 100;
    GlobalMin = 0;
    GlobalMax = 0;
    disp(['I`m randomly loading ' num2str(AmountOfSubScans * GrayValueLoadHowMany) ...
        ' tiffs from all SubScans to look for the minimal and maximal Grayvalue' ]);
    for CurrentSubScan=1:AmountOfSubScans
        SubScanDetails(CurrentSubScan).GrayMin = 0;
        SubScanDetails(CurrentSubScan).GrayMax = 0;
        disp(['Searching for minimal and maximal Grayvalue in ' num2str(GrayValueLoadHowMany) ...
            ' Projections from ' SubScanDetails(CurrentSubScan).SubScanName ]);
        w = waitbar(0,['Looking for minimal and maximal Grayvalue in SubScan ' num2str(CurrentSubScan) ]);
        for HM = 1:GrayValueLoadHowMany
            FileNumber = round(rand * SubScanDetails(CurrentSubScan).NumProj);
            if FileNumber == 0
                FileNumber = 1;
            end
            waitbar(HM/GrayValueLoadHowMany);
            % read in files for concatenation
            CurrentTifDir = [ SubScanDetails(CurrentSubScan).Location filesep 'tif' filesep ];
            % disp(['Reading File ' num2str(ceil((FileNumber/SubScanDetails(CurrentSubScan).ModuloToCenter)+NumDarks+NumFlats)) ]);
            FileToRead = [ CurrentTifDir filesep SubScanDetails(CurrentSubScan).SubScanName ...
                num2str(sprintf('%04d',ceil((FileNumber/SubScanDetails(CurrentSubScan).ModuloToCenter)+NumDarks+NumFlats))) ...
                '.tif'];
            TmpImage = imread(FileToRead);
            if NumFlats ~= 0
                if  NumFlats ~= 0
                    TmpImage = -log(double(TmpImage)./double(SubScanDetails(CurrentSubScan).AverageFlat));
                end
            end 
            % figure;imshow(TmpImage,[]);pause(0.05);close;
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
    disp('---');
    disp(['The global minimal grayvalue is ' num2str(GlobalMin) ','])
    disp(['the global maximal grayvalue is ' num2str(GlobalMax) '.']);
    warndlg('Confirm Greylevel values (Look in MATLABs window for accepting/correcting it','!! Warning !!')
    disp('Do you like these grey level values?');
    GreyValuesAreOK = input('[1]=yes, proceed, [0]=no, let me enter a better one: ');
	if GreyValuesAreOK == 0
        GlobalMin = input('Please enter your chosen minimal grey value (preferrably one from the logfile): ');
        GlobalMax = input('Please enter your chosen minimal grey value (preferrably one from the logfile): ');
        disp(['The NEW global minimal grayvalue is set to ' num2str(GlobalMin) ','])
        disp(['The NEW global maximal grayvalue is set to ' num2str(GlobalMax) '.']);
    end
    disp('---');
  
    %% loop over the images, calculate the cutline, save it for later and then
    %% perform the Merging
    
    %% Cutline Extraction
    %% Sample Orientation is crucial for Cutline Extraction, or else the
    %% cutline algorithm cannot calculate the cutline...
        %% set file-number medium if sample is oriented in direction of the beam
        %% at the start of the scan
        %% set file-number low if sample is perpendicular to beam at the start
        %% of the scan
    if isempty(Cutlines) % this is set on line ~29 for testing reasons, e.g. Cutline can be set arbitrarly...
        perpendicular = 0;
        if perpendicular == 0
            CutlineGenerationFileNumber = max(SubScanDetails(1).NumProj) / 2 + NumDarks + NumFlats + 1;
            % using NumProj from 1. SubScan, thus assuming this is the one with
            % the most projections...
            % -> use ProjectionImage @ 180 degrees
        else
            CutlineGenerationFileNumber = NumDarks + NumFlats + 1;
            % use first Projection Image
        end
        for CurrentSubScan=1:AmountOfSubScans
            SubScanDetails(CurrentSubScan).Cutline = Inf;
            % read in files for concatenation
            CurrentTifDir = [ SubScanDetails(CurrentSubScan).Location filesep 'tif' filesep ];
            CutFile = [ CurrentTifDir SubScanDetails(CurrentSubScan).SubScanName ...
                num2str(sprintf('%04d',ceil(( CutlineGenerationFileNumber/SubScanDetails(CurrentSubScan).ModuloToCenter) + NumDarks + NumFlats )))...
                '.tif'];
            SubScanDetails(CurrentSubScan).CurrentProjection = imread(CutFile);
            SubScanDetails(CurrentSubScan).CurrentProjection = -log(double(SubScanDetails(CurrentSubScan).CurrentProjection)./double(SubScanDetails(CurrentSubScan).AverageFlat));
            % compute Cutline
            if CurrentSubScan > 1 && isinf(SubScanDetails(CurrentSubScan-1).Cutline)
                disp(['Calculating cutline between ' SubScanDetails(CurrentSubScan-1).SubScanName ...
                    ' and ' SubScanDetails(CurrentSubScan).SubScanName ' (this will take some time...)']);
                SubScanDetails(CurrentSubScan-1).Cutline = ...
                    function_cutline((SubScanDetails(CurrentSubScan-1).CurrentProjection./SubScanDetails(CurrentSubScan-1).AverageFlat),(SubScanDetails(CurrentSubScan).CurrentProjection./SubScanDetails(CurrentSubScan-1).AverageFlat));
                disp('---');
                disp(['The cutline between ' SubScanDetails(CurrentSubScan-1).SubScanName ...
                    ' and ' SubScanDetails(CurrentSubScan).SubScanName ' is ' ...
                    num2str(SubScanDetails(CurrentSubScan-1).Cutline) 'px.']);
                warndlg('Confirm Cutlines please (Look in MATLABs window for accepting/correcting it','!! Warning !!')
                disp('Do you like this value as cutline?');
                CutLineIsOK = input('[1]=yes, proceed, [0]=no, let me enter a better one: ');
                if CutLineIsOK == 0
                     disp(['Enter new cutline between ' SubScanDetails(CurrentSubScan-1).SubScanName ...
                    ' and ' SubScanDetails(CurrentSubScan).SubScanName ':']);
                    SubScanDetails(CurrentSubScan-1).Cutline = input('[px] ');
                    disp(['The NEW cutline between ' SubScanDetails(CurrentSubScan-1).SubScanName ...
                    ' and ' SubScanDetails(CurrentSubScan).SubScanName ' is ' ...
                    num2str(SubScanDetails(CurrentSubScan-1).Cutline) 'px.']);
                disp('---');
                end
            end
        end
    else % isempty(Cutlines)
        for CurrentSubScan=1:AmountOfSubScans
            for counter = 1:AmountOfSubScans
            	SubScanDetails(counter).Cutline = Inf;
            end
            for counter = 1:AmountOfSubScans - 1
            	SubScanDetails(counter).Cutline = 0;
            end
            disp([ 'The Cutlines have been set to "' num2str(SubScanDetails(1).Cutline) ...
                '" for testing purposes (change at the beginning of fct_mergeSubScanSelector")!' ]);
        end
    end % isempty(Cutlines)
    
    %% Merge Files
    FromToTo = 1:WriteEveryXth:max([SubScanDetails.NumProj]); % go from zero to maximal amount of NumProj
    w = waitbar(0,['Writing ' num2str(length(FromToTo)) ' merged Projections of ' OutputSampleName OutputSuffix '_mrg to Disk.' ]);
    if Tiff == 1
        disp(['Writing ' num2str(length(FromToTo)) ' merged Projections of ' OutputSampleName OutputSuffix '_mrg as .tif.'])
    elseif Tiff == 0
        disp(['Writing ' num2str(length(FromToTo)) ' merged Projections of ' OutputSampleName OutputSuffix '_mrg as .DMP.'])
    end % writeDMP

    InterpolationCounter = 1;
    InterpolatedImage = [];
    for FileNumber = FromToTo
        waitbar(FileNumber/max(FromToTo));
        disp([ '----' num2str(FileNumber) '----' ]);
        for CurrentSubScan=1:AmountOfSubScans
            % read in files for concatenation
            CurrentTifDir = [ SubScanDetails(CurrentSubScan).Location filesep 'tif' filesep ];
            FileToMerge = [ CurrentTifDir SubScanDetails(CurrentSubScan).SubScanName ...
                num2str(sprintf('%04d',ceil(( FileNumber/SubScanDetails(CurrentSubScan).ModuloToCenter) + NumDarks + NumFlats ))) ...
                '.tif'];
            disp([ 'SubScanDetails(CurrentSubScan).ModuloToCenter)) is ' num2str(SubScanDetails(CurrentSubScan).ModuloToCenter) ]);
            SubScanDetails(CurrentSubScan).CurrentProjection = imread(FileToMerge);
            %% we're actually interpolating here > load the two images into
            %% temporary stack and choose the correct image from this stack
            if SubScanDetails(CurrentSubScan).ModuloToCenter ~= 1
                disp([ 'We thus need to interpolate ' num2str(SubScanDetails(CurrentSubScan).ModuloToCenter-1) ' image(s) here.' ]);
                if InterpolationCounter > SubScanDetails(CurrentSubScan).ModuloToCenter
                    InterpolatedImage = [];
                    InterpolationCounter = 1;
                    disp([ 'InterpolationCounter set to ' num2str(InterpolationCounter) ]);
                end                 
                if isempty(InterpolatedImage)
                    ImageToInterpolate1 = [ CurrentTifDir SubScanDetails(CurrentSubScan).SubScanName ...
                        num2str(sprintf('%04d',ceil(( FileNumber/SubScanDetails(CurrentSubScan).ModuloToCenter) + NumDarks + NumFlats ))) ...
                        '.tif'];
                    if FileNumber >= max(FromToTo)-SubScanDetails(CurrentSubScan).ModuloToCenter 
                        % If Files to be read are the last set to be
                        % interpolated, we cannot load any further files,
                        % so we actually perform a fake interpolation for
                        % the last set of ModuloToCenter-Slices, since we
                        FileNumber = max(FromToTo)-SubScanDetails(CurrentSubScan).ModuloToCenter;
                    end
                    ImageToInterpolate2 = [ CurrentTifDir SubScanDetails(CurrentSubScan).SubScanName ...
                        num2str(sprintf('%04d',ceil(( (FileNumber+SubScanDetails(CurrentSubScan).ModuloToCenter)/SubScanDetails(CurrentSubScan).ModuloToCenter) + NumDarks + NumFlats ))) ...
                        '.tif'];
                    disp([ 'reading ' ImageToInterpolate1 ])
                    disp([ 'reading ' ImageToInterpolate2 ])
                    ImageToInterpolate1 = double(imread(ImageToInterpolate1));
                    ImageToInterpolate2 = double(imread(ImageToInterpolate2));
                    disp('--Generating InterpolatedImage--')                        
                    InterpolatedImage = fct_ImageInterpolator(ImageToInterpolate1,ImageToInterpolate2,SubScanDetails(CurrentSubScan).ModuloToCenter);
%                     figure
%                         subplot(121)
%                             imshow(InterpolatedImage(:,:,1),[])
%                             title('to interpolate from')
%                         subplot(122)
%                             imshow(InterpolatedImage(:,:,end),[])
%                             title('to interpolate to')
                end
                disp([ 'Using slice ' num2str(InterpolationCounter) ' from interpolated image-stack.' ])
                SubScanDetails(CurrentSubScan).CurrentProjection = InterpolatedImage(:,:,InterpolationCounter); % overwrite already loaded file with interpolated slice
                InterpolationCounter = InterpolationCounter + 1;
            end
            
            %% correct the images with darks and flats if necessary
            if NumDarks ~= 0
                SubScanDetails(CurrentSubScan).CurrentProjection = -log(double(SubScanDetails(CurrentSubScan).CurrentProjection)./double(SubScanDetails(CurrentSubScan).AverageFlat));
            end
        end
                
        % merge the files to a big projection, depending on what the
        % cutline-function gives out in different sequences...
        if AmountOfSubScans == 3
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
        
%         if ~isempty(OutputSampleName) % if User Specified a new name to save under, use this one from now on...
%             SampleName = OutputSampleName;
%         end
        
        % Write Tiffs 
        if Tiff == 1
            % mkdir for merged Proj
            WriteDir = [ WritePath filesep 'mrg' filesep OutputSampleName OutputSuffix '_mrg' filesep 'tif' ];
            InLogFileDir = [ '/sls/X02DA/data' filesep UserID filesep 'Data3' filesep BeamTime filesep 'mrg' filesep OutputSampleName OutputSuffix '_mrg' filesep 'tif' ];
            [success,message,messageID] = mkdir(WriteDir);
            % disp(['writing ' OutputSampleName - ' OutputSuffix '_mrg' num2str(sprintf('%04d',FileNumber)) '.tif to disk'])
            WriteTifName = [ WriteDir filesep OutputSampleName OutputSuffix '_mrg' num2str(sprintf('%04d',FileNumber)) ];
            if NumDarks ~= 0 && NumFlats ~= 0
                MergedProjection = MergedProjection - GlobalMin;
                MergedProjection = MergedProjection ./ GlobalMax;
            end
            % write .tif
            imwrite(MergedProjection,[ WriteTifName '.tif' ],'Compression','none');  % Compression none, so that ImageJ can read the tiff-files...
        end % writeTif
        % write DMPs
        if Tiff == 0
            % mkdir for merged Proj
            WriteDir = [ WritePath filesep 'mrg' filesep OutputSampleName OutputSuffix '_mrg' filesep 'DMP' ];
            [success,message,messageID] = mkdir(WriteDir);
            % disp(['writing ' OutputSampleName OutputSuffix '_mrg' num2str(sprintf('%04d',FileNumber)) '.DMP to disk'])
            WriteDMPName = [ WriteDir filesep OutputSampleName OutputSuffix '_mrg' num2str(sprintf('%04d',FileNumber)) ];
            writeDumpImage(MergedProjection,[WriteDMPName '.DMP']);
        end % writeDMP
        
        clear MergedProjection;
        
    end % FileNumberLoop
    %close(w);
    %%%%%%%%%%%%%%%%%
    % generate fake LogFile
    %%%%%%%%%%%%%%%%%
   
    LogFileName = [ OutputSampleName OutputSuffix '_mrg.log' ];
    LogFile = [ WriteDir filesep LogFileName ]; % WriteDir is used from above, so we have different paths depending on tif/DMP.
    WriteSampleName = [ OutputSampleName OutputSuffix '_mrg' ];

    disp('----');
    disp(['Generating fake logfile for the sample ' WriteSampleName '.' ]);

    %% write the stuff to a faked log-file.    
    % User ID : e11126
    dlmwrite(LogFile, ['User ID : ' UserID],'delimiter','');
    % FAST-TOMO scan of sample R108C60c_s1 started on Mon Oct 06 18:51:01 2008 
    dlmwrite(LogFile, ['Merged Scan of sample ' WriteSampleName ' generated from ' num2str(AmountOfSubScans) ' SubScans. Log was faked on ' datestr(now) ],'-append','delimiter','');
    % --------------------Beamline Settings-------------------------
    dlmwrite(LogFile, ['--------------------Beamline Settings-------------------------'],'-append','delimiter','');
    % Ring current [mA]           : 400.650 
    dlmwrite(LogFile, ['Ring current [mA]           : (see original Logfile of ' SubScanDetails(1).SubScanName ')' ],'-append','delimiter','');
    % Beam energy  [keV]          : 15.072 
    dlmwrite(LogFile, ['Beam energy  [keV]          : (see original Logfile of ' SubScanDetails(1).SubScanName ')' ],'-append','delimiter','');
    % Monostripe                  : Ru/C 
    dlmwrite(LogFile, ['Monostripe                  : (see original Logfile of ' SubScanDetails(1).SubScanName ')' ],'-append','delimiter','');
    % --------------------Detector Settings-------------------------
    dlmwrite(LogFile, ['--------------------Detector Settings-------------------------'],'-append','delimiter','');
    % Objective                   : 10.00 
    dlmwrite(LogFile, ['Objective                   : (see original Logfile of ' SubScanDetails(1).SubScanName ')' ],'-append','delimiter','');
    % Scintillator                : YAG:Ce 18 um 
    dlmwrite(LogFile, ['Scintillator                : (see original Logfile of ' SubScanDetails(1).SubScanName ')' ],'-append','delimiter','');
    % Exposure time [ms]          : 500 
    dlmwrite(LogFile, ['Exposure time [ms]          : (see original Logfile of ' SubScanDetails(1).SubScanName ')' ],'-append','delimiter','');
    % ------------------------Scan Settings-------------------------
    dlmwrite(LogFile, ['------------------------Scan Settings-------------------------'],'-append','delimiter','');
    % Sample folder                : /sls/X02DA/data/e11126/Data10/2008b/R108C60c_s1 
    dlmwrite(LogFile, ['Sample folder                : ' InLogFileDir ],'-append','delimiter',''); %InLogFileDir makes sure that we always have the correct location in the logfile, also when the Files have been merged using "blmount" on some computer...
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
    dlmwrite(LogFile, ['Rot Y min position  [deg]    : (see original Logfile of ' SubScanDetails(1).SubScanName ')' ],'-append','delimiter','');
    % Rot Y max position  [deg]    : 225.000 
    dlmwrite(LogFile, ['Rot Y max position  [deg]    : (see original Logfile of ' SubScanDetails(1).SubScanName ')' ],'-append','delimiter','');
    % Angular step [deg]           : 0.039 
    dlmwrite(LogFile, ['Angular step [deg]           : (see original Logfile of ' SubScanDetails(1).SubScanName ')' ],'-append','delimiter','');
    % Sample In   [um]             : -1442 
    dlmwrite(LogFile, ['Sample In   [um]             : (see original Logfile of ' SubScanDetails(1).SubScanName ')' ],'-append','delimiter','');
    % Sample Out  [um]             : 10000 
    dlmwrite(LogFile, ['Sample Out  [um]             : (see original Logfile of ' SubScanDetails(1).SubScanName ')' ],'-append','delimiter','');
    % --------------------------------------------------------------
    dlmwrite(LogFile, ['--------------------------------------------------------------'],'-append','delimiter','');
    % Start logging activity...
    dlmwrite(LogFile, ['Start logging activity...'],'-append','delimiter','');% Start logging activity...
    dlmwrite(LogFile, ['It`s a fake log-file, believe me!'],'-append','delimiter','');
    dlmwrite(LogFile, ['But the stuff below might be of value again...'],'-append','delimiter','');
    dlmwrite(LogFile, ['--------------------------------------------------------------'],'-append','delimiter','');
    dlmwrite(LogFile, ['Cutline between SubScan 1 and 2: ' num2str(SubScanDetails(1).Cutline) ' pixels' ],'-append','delimiter','');
    dlmwrite(LogFile, ['Cutline between SubScan 2 and 3: ' num2str(SubScanDetails(2).Cutline) ' pixels' ],'-append','delimiter','');
    if AmountOfSubScans == 5
        dlmwrite(LogFile, ['Cutline between SubScan 3 and 4: ' num2str(SubScanDetails(3).Cutline) ' pixels'],'-append','delimiter','');
        dlmwrite(LogFile, ['Cutline between SubScan 4 and 5: ' num2str(SubScanDetails(4).Cutline) ' pixels'],'-append','delimiter','');
    end
    dlmwrite(LogFile, ['--------------------------------------------------------------'],'-append','delimiter','');
    dlmwrite(LogFile, ['Minmal Grey level Value calculated by MATLAB: ' num2str(GlobalMin)  ],'-append','delimiter','');
    dlmwrite(LogFile, ['Minmal Grey level Value calculated by MATLAB: ' num2str(GlobalMax)  ],'-append','delimiter','');
    dlmwrite(LogFile, ['--------------------------------------------------------------'],'-append','delimiter','');
    
    disp('----');
    
    %% hardlink logfiles
    LogFileDir = [ WritePath filesep 'mrg' filesep 'log' ];
    [success,message,messageID] = mkdir(LogFileDir);
    if isunix == 1 % only works if @TOMCAT or @slslc05
        logfilecommand = [ 'ln ' LogFile ' ' WritePath filesep 'mrg' filesep 'log' filesep LogFileName ];
        disp(['Hard-Linking LogFile ' OutputSampleName OutputSuffix '_mrg.log with the command:']);
        disp([ '"' logfilecommand '"' ]);
        system(logfilecommand);
    end
    
    disp('----');
    %% generate sinograms
    if isunix == 1 % only works if @TOMCAT,x02da-cons-2 or @slslc05...\
        % WORKAROUND FOR NON-DISCOVERED BUG IN OLD PRJ2SIN, USES LOCAL COPY
        % AT THE MOMENT
            sinogramcommand = [ '~/Data3/sinooff_tomcat_j.py ' WriteDir ];
        % WORKAROUND FOR NON-DISCOVERED BUG IN OLD PRJ2SIN, USES LOCAL COPY
        % AT THE MOMENT
            %sinogramcommand = [ '/work/sls/bin/sinooff_tomcat_j.py ' WriteDir ];
        disp(['Generating Sinograms for ' OutputSampleName OutputSuffix '_mrg with:']);
        disp([ '"' sinogramcommand '"' ]);
        system(sinogramcommand);
    end
   	disp('----');
    
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
            OutputSampleName OutputSuffix '_mrg' ]);
    end    
	disp('---');
    
cd(currentLocation);
end
