clear;
clc;
close all;

%% Set Parameters
Filename = 'R108C60_22_20x_A_';
OutputName = [Filename 'conc_sino_'];
[s,mess,messid]=mkdir(['/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_sinog/' OutputName ]);
% Description of the subprotocols
Names = str2mat('lf','ct','rt');

DarkImage = single(imread(['/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/' ...
        num2str(Filename) num2str(Names(1,:)) '/tif/' num2str(Filename) ...
        num2str(Names(1,:)) '0001.tif']));
FlatImage = single(imread(['/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/' ...
        num2str(Filename) num2str(Names(1,:)) '/tif/' num2str(Filename) ...
        num2str(Names(1,:)) '0003.tif']));
FlatImage = log(FlatImage-DarkImage);

h = waitbar(0,'I`m working, please wait...');
% how many images should be concatenated an `sinogrammed` (max. 3001)

maxImgNum = 3001;

% this many Sinograms are generated...
for SinogramRow = 512
    progress = waitbar(0,['I`m working on sinogram ' num2str(SinogramRow) ', please wait...']);
    for ImageNumber=2600:maxImgNum
        ImageNumberStr = [ sprintf('%04d',ImageNumber+4) ; sprintf('%04d',ImageNumber) ];
        ConcatenatedImage = h_ConcatenateImagesA(Filename,ImageNumberStr,Names,DarkImage,FlatImage);
    %     figure(1);
    %         imshow(ConcatenatedImage,[]);
        %disp(['done with image number ' ImageNumberStr(2,:)]);
        Sinogram(ImageNumber,:) = ConcatenatedImage(SinogramRow,:);
        waitbar(ImageNumber/maxImgNum)
    end
    close(progress) 
    figure;
        imshow(Sinogram,[]);

%% Save Sinogram to disk
SinogramRow = sprintf('%04d',SinogramRow);
imwrite(Sinogram,['/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_sinog/' ...
    num2str(OutputName) '/' num2str(OutputName) num2str(SinogramRow) '.sin.tif']);
end
