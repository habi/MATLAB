function ConcatenateImage = h_ConcatenateImages(Filename,ImageNumber,Names)

%% Clear Workspace
% clear;
% clc;
% close all;
tic; % start timer

%% Set Parameters
Filename = 'R108C60_22_20x_A_';
ImageNumber = '1011';
% Description of the subprotocols
Names = str2mat('lf', 'ct', 'rt');
% Names = str2mat('lf', 'ct');
% Desired Output-Name
OutputName = [Filename 'conc_'];
mkdir(['/afs/psi.ch/user/h/haberthuer/MATLAB/testing/x02da/e11126/Data2/' OutputName]);

%% Load Images and concatenate them
for counter = 1:size(Names,1)
    % read in Image with 'filename' 'name' and 'filenumber'
    InputImage = imread(['/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/' ...
        num2str(Filename) num2str(Names(counter,:)) '/tif/' num2str(Filename) ...
        num2str(Names(counter,:)) num2str(ImageNumber) '.tif']);
    % make an empty image the size of the InputImage with size(Names)
    % dimensions (to store the InputImages as 'slices'
    TmpImage(size(InputImage,1),size(InputImage,2),size(Names,1)) = NaN;
    % put the 'counter' InputImage into the 'counter' slice
    TmpImage(:,:,counter) = InputImage;
    % make a big Image
    if size(Names,1) == 2
    ConcatenatedImage=[ TmpImage(:,:,1) TmpImage(:,:,2)];
    end
    if size(Names,1) == 3
    ConcatenatedImage=[ TmpImage(:,:,1) TmpImage(:,:,2) TmpImage(:,:,3)];
    end
    figure(1)
        colormap gray;
        imshow(ConcatenatedImage,[]);
        title(['Concatenated Image with a size of ' num2str(size(ConcatenatedImage,1)) ...
            ' x ' num2str(size(ConcatenatedImage,2)) ' px']);
        axis image;
end

%% Display the single Image(s)
for counter = 1:size(Names,1)
    figure(counter+1)        
        colormap gray;
        imshow(TmpImage(:,:,counter),[]);
        title([num2str(Names(counter,:)) ' Image with a size of ' num2str(size(TmpImage,1)) ...
            ' x ' num2str(size(TmpImage,2)) ' px']);
        axis image;
end
     
%% Save Concatenated Image
% close all;
% size(ConcatenatedImage);
ConcatenatedImage = ConcatenatedImage ./ max(max(ConcatenatedImage));
imwrite(ConcatenatedImage,['/afs/psi.ch/user/h/haberthuer/MATLAB/testing/x02da/e11126/Data2/' ...
    OutputName '/tif' OutputName ImageNumber '.tif'],'tif');
% imwrite(ConcatenatedImage,['/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/' ...
%     num2str(OutputName) '/tif/' num2str(OutputName) num2str(ImageNumber) '.tif']);

%% Output Timer
close all;
toc

end