%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reads DICOM-Files exported with
% p:\doc\MeVisLab-Networks\2011\ExtractAcinusAndExport.mlab and save them
% as JPG image sequences to further peruse with the STEPanizer.com
% First version: 20.06.2011, reading and displaying the DICOM-file

clc
clear all
close all

Path = 'd:\SLS\'
Beamtime = '2010a'

[DICOMFileName PathToDICOMFile] = uigetfile({'*.dcm','DICOM File';'*.dcm','All Files' },['Open a DICOM file from Beamtime ' Beamtime],[Path Beamtime filesep '*.dcm'])

%2010a\mrg\R108C21Bt-mrg\R108C21Bt-mrg.2934x2934x1024.gvr.acinus25.vx11.84um.vol0.023242ul25.volume0.023242148.pixelsize0.00296000018715858.dcm

DICOMFile = uint8(dicomread([PathToDICOMFile DICOMFileName]));

%% Show slices of the DICOM-File
slices = size(DICOMFile,4);
figure
    for ctr=1:(subplotrows^2)
        subplot(subplotrows,subplotrows,ctr)
        showslice = round(slices/(subplotrows^2)*ctr);
        imshow(DICOMFile(:,:,showslice),[]);
        title(['Slice ' num2str(showslice)])
    end
    
%% Extract SampleName and Number of Acinus and make directory to save slices into
SampleNameStartPointer = regexp(PathToDICOMFile, 'R108', 'once');
SampleName = PathToDICOMFile(SampleNameStartPointer:end-1)

AcinusStartPointer = regexp(DICOMFileName, 'acinus', 'once');
AcinusEndPointer = regexp(DICOMFileName, '.vx', 'once');
AcinusName = DICOMFileName(AcinusStartPointer:AcinusEndPointer-1)
AcinusPath = [PathToDICOMFile AcinusName]
mkdir(AcinusPath)

%% write out image as slices into the above generated directory
for slice = 1:slices
    disp(['writing file ' num2str(slice) '/' num2str(slices)])
    WriteFileName = [ SampleName '-' AcinusName '-' num2str(slice) '.jpg' ];
    imwrite(DICOMFile(:,:,slice),[AcinusPath filesep WriteFileName]);
end
