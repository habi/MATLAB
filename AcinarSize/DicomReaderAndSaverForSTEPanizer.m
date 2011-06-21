%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reads DICOM-Files exported with
% p:\doc\MeVisLab-Networks\2011\ExtractAcinusAndExport.mlab and save them
% as JPG image sequences to further peruse with the STEPanizer.com
% First version: 20.06.2011, reading and displaying the DICOM-file

clc
clear all
close all

Path = 'd:\SLS\';
Beamtime = '2010a';

Scalebar = 100; % micrometer
Iteration = 2;

[DICOMFileName PathToDICOMFile] = uigetfile({'*.dcm','DICOM File';'*.dcm','All Files' },['Open an exported DICOM file from Beamtime ' Beamtime],[Path Beamtime filesep '*.dcm']);

DICOMFile = uint8(dicomread([PathToDICOMFile DICOMFileName]));

%% Show slices of the DICOM-File
slices = size(DICOMFile,4);
subplotrows = 4;
figure
    for ctr=1:(subplotrows^2)
        subplot(subplotrows,subplotrows,ctr)
        showslice = round(slices/(subplotrows^2)*ctr);
        imshow(DICOMFile(:,:,showslice),[]);
        title(['Slice ' num2str(showslice)])
    end
pause(0.001)

%% Extract SampleName and Number of Acinus and make directory to save slices into
SampleNameStartPointer = regexp(PathToDICOMFile, 'R108', 'once');
SampleName = PathToDICOMFile(SampleNameStartPointer:end-1);

VoxelSizeStartPointer = regexp(DICOMFileName, 'pixelsize', 'once');
VoxelSize = 1000*str2num(DICOMFileName(VoxelSizeStartPointer+9:end-4)); % VoxelSize in micrometer

VolumeStartPointer = regexp(DICOMFileName, 'volume', 'once');
VolumeEndPointer = regexp(DICOMFileName, 'pixelsize', 'once');
Volume = DICOMFileName(VolumeStartPointer+6:VolumeEndPointer-2);

AcinusStartPointer = regexp(DICOMFileName, 'acinus', 'once');
AcinusEndPointer = regexp(DICOMFileName, '.volume', 'once');
AcinusName = DICOMFileName(AcinusStartPointer:AcinusEndPointer-1);
AcinusPath = [PathToDICOMFile AcinusName filesep 'voxelsize' num2str(VoxelSize) '-every' num2str(Iteration) 'slice' ];
mkdir(AcinusPath)

figure
SliceCounter = 1
for slice = 1:Iteration:slices
    clc
    disp(['writing file ' num2str(slice) '/' num2str(slices)])
    WriteFileName = [ SampleName '-' AcinusName '-' num2str(SliceCounter) '.jpg' ];
    SliceCounter = SliceCounter + 1;
    % Make Scalebar
    CurrentSlice = DICOMFile(:,:,slice);
    ScaleBarLength = round(Scalebar/VoxelSize);
    CurrentSlice(size(DICOMFile,1)-10-(round(ScaleBarLength/10)):size(DICOMFile,1)-10,10:10+ScaleBarLength) = 255; % draw Scalebar of length(ScaleBarLength) in the bottom left corner, with 10 times the length of the height.
    imshow(CurrentSlice,[])
        title(['writing file ' num2str(slice) '/' num2str(slices)])
    pause(0.001)
    imwrite(CurrentSlice,[AcinusPath filesep WriteFileName]);
end

disp(['I have written ' AcinusName ' with Volume ' num2str(Volume) ' to ' AcinusPath filesep SampleName '-' AcinusName '-x.jpg']);
disp(['I have witten every ' num2str(Iteration) ' slice!'])
disp(['The scalebar on the image is ' num2str(Scalebar) ' micrometer long.'])