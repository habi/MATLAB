clc;clear all;close all;

addpath('P:\MATlAB\helpers');
addpath('P:\matlab\wideFieldScan');

width = 256;
split = 128;
overlap = 10;

baseImage = phantom(width);
%baseImage = imnoise(baseImage,'gaussian');

disp(['The original Image has a size of ' num2str(size(baseImage,1)) 'x' num2str(size(baseImage,2)) ' pixels.'])

Image1 = baseImage(:,1:split+overlap);
Image2 = baseImage(:,split-overlap+1:end);

Image1 = imnoise(Image1,'gaussian');
Image2 = imnoise(Image2,'gaussian');

disp(['Image 1 has a size of ' num2str(size(Image1,1)) 'x' num2str(size(Image1,2)) ' pixels.'])
disp(['Image 2 has a size of ' num2str(size(Image2,1)) 'x' num2str(size(Image2,2)) ' pixels.'])
        
ctline = function_cutline(Image1,Image2);
if ctline < 1
    disp('The calculated cutline is still below 1, I cannot correctly merge the images and am stopping here...')
	break
end
disp(['The calculated cutline between the images is @ ' num2str(ctline) ' pixels.'])

%% merge
Image1 = imadd(Image1,.125);
mergedImage = [ Image1 Image2(:,ctline+1:end)];

%% add to distinguish visually
% mergedImage(1:width,1:width) = NaN;
% mergedImage(:,1:size(Image1,2)) = Image1;
% mergedImage(:,size(Image1,2)+1:end) = Image2(:,ctline+1:end);

disp(['The merged Image has a size of ' num2str(size(mergedImage,1)) 'x' num2str(size(mergedImage,2)) ' pixels.'])       

%% show Phantom with overlayed splitlines, Image1 and Image2 and merged image with cutline
scrsz = get(0,'ScreenSize');
figure('Position',[100 100 1500 512])
    subplot(141)
    	imshow(baseImage,[]);
        vline(split+overlap,'g');
        vline(split-overlap+1,'g');
        vline(split,'r','SplitLine');
        title('Original Image')
        axis on
        colormap jet
    subplot(142)
    	imshow(Image1,[]);
        vline(size(Image1,2)-ctline,'g','overlap');        
        title('s_1')
        axis on
    subplot(143)
    	imshow(Image2,[]);
        vline(ctline,'g','overlap');        
        title('s_2')        
        axis on image
    subplot(144)
    	imshow(mergedImage,[]);
        vline(size(Image1,2),'g','cutline');
        title('Merged Image')
        axis on