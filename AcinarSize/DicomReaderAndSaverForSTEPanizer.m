%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reads DICOM-Files exported with
% p:\doc\MeVisLab-Networks\2011\ExtractAcinusAndExport.mlab and save them
% as JPG image sequences to further peruse with the STEPanizer.com
% First version: 20.06.2011, reading and displaying the DICOM-file
% 28.07.2011: Now reads ALL the DICOM-Files in the directory selected on
% Line 16 and converts them in one batch.

clc
clear all
close all

%% 60A - 
%% 60B - 2010c
%% 60C - 2010a
%% 60D - 2009f
%% 60E - 2009f

Scalebar = 100; % micrometer
Disector = 1; % 1=Do export for Disector, 0=Just export slices with the "SliceDistance".
DisectorThickness = 3; % IN SLICES!
SliceDistance = 10;
if DisectorThickness>=SliceDistance
    disp(['DisectorThickness (' num2str(DisectorThickness) ') is equal or larger than Slicedistance (' num2str(SliceDistance) '), please redefine in MATLAB-File'])
    break
end

SamplePath = uigetdir('d:\SLS\','Select *Directory* of the Sample you want to convert the DICOM-Files from MeVisLab to JPG for STEPanizer');

disp([ 'Counting DICOM-Files in ' SamplePath ]);         
filelist = dir([SamplePath filesep '*.dcm']);
NumberOfDICOMFiles = size(filelist,1);
disp([ 'Found ' num2str(NumberOfDICOMFiles) ' DICOMs in ' SamplePath]);

%% Iterate through all the files found in the directory and save them do
%% JPG-slices
for i=1:NumberOfDICOMFiles 
    disp([ 'Saving ' filelist(i).name ' to JPG-slices']);
    
    PathToDICOMFile = [SamplePath filesep]; % Carried over from first manual script, just leave it for the moment...
    DICOMFileName = filelist(i).name; % Carried over from first manual script
    
    %% Extract SampleName and Number of Acinus and make directory to save slices into
    SampleNameStartPointer = regexp(PathToDICOMFile, 'R108', 'once');
    SampleName = PathToDICOMFile(SampleNameStartPointer:end-1);

    VoxelSizeStartPointer = regexp(DICOMFileName, 'pixelsize', 'once');
    VoxelSize = 1000*str2num(DICOMFileName(VoxelSizeStartPointer+9:end-4)); % VoxelSize in micrometer
    ScaleBarLength = round(Scalebar/VoxelSize);

    VolumeStartPointer = regexp(DICOMFileName, 'volume', 'once');
    VolumeEndPointer = regexp(DICOMFileName, 'pixelsize', 'once');
    Volume = DICOMFileName(VolumeStartPointer+6:VolumeEndPointer-2);

    AcinusStartPointer = regexp(DICOMFileName, 'acinus', 'once');
    AcinusEndPointer = regexp(DICOMFileName, '.volume', 'once');
    AcinusNumber = DICOMFileName(AcinusStartPointer+6:AcinusEndPointer-1); % remove "acinus", so we can format the number nicely
    AcinusNumber = (sprintf('%02d',str2num(AcinusNumber))); % format string to number and pad with zero if necessary
    AcinusName = [ 'acinus' AcinusNumber ];
    if Disector == 0
        AcinusPath = [PathToDICOMFile AcinusName filesep 'voxelsize' ...
            num2str(VoxelSize) '-every' num2str(SliceDistance) 'slice' ];
    elseif Disector == 1
        AcinusPath = [PathToDICOMFile AcinusName filesep 'voxelsize' num2str(VoxelSize) ...
            '-every' num2str(SliceDistance) 'slice-DisectorThickness-' num2str(sprintf('%1.2f',DisectorThickness * VoxelSize)) ...
            'um-or' num2str(DisectorThickness) 'slices' ];
    else
        warndlg('Please set Disector to either 0 or 1');
        break        
    end
    [status,message,messageid] = mkdir(AcinusPath);
        
    %% actually read File
    disp([ 'Reading File ' num2str(i) '/' num2str(NumberOfDICOMFiles) ]);
        
    DICOMFile = double(dicomread([PathToDICOMFile DICOMFileName])); % read in DICOM File as double
    DICOMFile = DICOMFile / max(max(max(DICOMFile))).*255; % scale to a maximum value of 255, still in double
    
    %% Show slices of the DICOM-File
    slices = size(DICOMFile,4);
%     subplotrows = 4;
%      figure
%          for ctr=1:(subplotrows^2)
%             subplot(subplotrows,subplotrows,ctr)
%             showslice = round(slices/(subplotrows^2)*ctr);
%             imshow(DICOMFile(:,:,showslice),[]);
%             title(['Slice ' num2str(showslice)])
%          end
%     pause(0.001)
   
    disp('---');
    
    %% Write out Slices to JPG images
    % figure
    SliceCounter = 0;
    for slice = 1:SliceDistance:slices
        disp(['writing file ' num2str(slice) '/' num2str(slices)])      
        SliceCounter = SliceCounter + 1;
        % Pad CurrentSlice to square size of longer side
        CurrentSlice = ones(max(size(DICOMFile(:,:,slice)))).*255; % Make square image with larger length of original DICOM file (white square)
        if Disector == 0
            CurrentSlice(1:size(DICOMFile(:,:,slice),1),1:size(DICOMFile(:,:,slice),2)) = DICOMFile(:,:,slice); % Write slice of DICOM file to top left corner of white square of above line
            CurrentSlice = uint8(CurrentSlice); % convert to uint8 before saving and displaying
            % Make Scalebar
            CurrentSlice(size(DICOMFile,1)-10-(round(ScaleBarLength/10)):size(DICOMFile,1)-10,10:10+ScaleBarLength) = 255; % draw Scalebar of length(ScaleBarLength) in the bottom left corner, with 10 times the length of the height.
            WriteFileName = [ SampleName '-' AcinusName '_' num2str(SliceCounter) '.jpg' ];
            imwrite(CurrentSlice,[AcinusPath filesep WriteFileName]);
        else
            if slice+DisectorThickness<=size(DICOMFile,4) % only try to write slice if we actually can and if the next slice (for disector) is not out of bounds.
                % write slice as "_a.jpg"
                CurrentSlice(1:size(DICOMFile(:,:,slice),1),1:size(DICOMFile(:,:,slice),2)) = DICOMFile(:,:,slice); % Write slice of DICOM file to top left corner of white square of above line
                CurrentSlice = uint8(CurrentSlice); % convert to uint8 before saving and displaying
                % Make Scalebar
                CurrentSlice(size(DICOMFile,1)-10-(round(ScaleBarLength/10)):size(DICOMFile,1)-10,10:10+ScaleBarLength) = 255; % draw Scalebar of length(ScaleBarLength) in the bottom left corner, with 10 times the length of the height.
                WriteFileName = [ SampleName '-' AcinusName '_' num2str(SliceCounter) '_a.jpg' ];
                imwrite(CurrentSlice,[AcinusPath filesep WriteFileName]);
                % write successive slice as "_b.jpg"
                CurrentSlice(1:size(DICOMFile(:,:,slice),1),1:size(DICOMFile(:,:,slice),2)) = DICOMFile(:,:,slice+DisectorThickness); % Write 'slice+DisectorThickness' of DICOM file to top left corner of white square of above line
                CurrentSlice = uint8(CurrentSlice); % convert to uint8 before saving and displaying
                % Make Scalebar
                CurrentSlice(size(DICOMFile,1)-10-(round(ScaleBarLength/10)):size(DICOMFile,1)-10,10:10+ScaleBarLength) = 255; % draw Scalebar of length(ScaleBarLength) in the bottom left corner, with 10 times the length of the height.
                WriteFileName = [ SampleName '-' AcinusName '_' num2str(SliceCounter) '_b.jpg' ];
                imwrite(CurrentSlice,[AcinusPath filesep WriteFileName]);
            end
        end
    end
    
    %% Give out some info
    disp(['I have written ' AcinusName ' with Volume ' num2str(Volume) ' to ' AcinusPath filesep SampleName '-' AcinusName '-x.jpg']);
    disp(['I have witten every ' num2str(SliceDistance) 'th slice!'])
    disp(['The scalebar on the image is ' num2str(Scalebar) ' micrometer long.'])
	clear DICOMFile
    disp('---')
    pause(0.001)
    close all
	
end
disp('Finished!')