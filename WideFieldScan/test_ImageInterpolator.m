clc;
clear all;
close all;

Image1 = imread('s:\SLS\2008c\R108C21Cb_s2\tif\R108C21Cb_s20032.tif');
Image2 = imread('s:\SLS\2008c\R108C21Cb_s2\tif\R108C21Cb_s21024.tif');

Image1 = imread('p:\#Images\MergeProjectionsTest\Numbers_s3\tif\Numbers_s30001.tif');
Image2 = imread('p:\#Images\MergeProjectionsTest\Numbers_s3\tif\Numbers_s30003.tif');

% StartFrom = 512;
% AmountOfImages = 2;
% 
% for Image = 1:AmountOfImages
%     disp([ 'Reading Image Nr. ' num2str(Image) ' of ' num2str(AmountOfImages) ])
%     ImageNumber = sprintf('%04d',StartFrom+Image);
%     ImageStack(:,:,Image) = imread(['s:\SLS\2008c\R108C21Cb_s2\tif\R108C21Cb_s2' num2str(ImageNumber) '.tif' ]);
% end

InterpolatedImageStack = fct_ImageInterpolator(Image1,Image2,1);

if isempty(InterpolatedImageStack)
    break
end
    
scrsz = get(0,'ScreenSize');
colormap = [ 0 max(max(max(InterpolatedImageStack))) ];

figure('Position',[32 256 scrsz(3)-64 384])
	subplot(1,size(InterpolatedImageStack,3),1)
        imshow(InterpolatedImageStack(:,:,1),colormap)
        title(['Original Slice 1'])
    for ctr=2:size(InterpolatedImageStack,3)-1
        subplot(1,size(InterpolatedImageStack,3),ctr)
            imshow(InterpolatedImageStack(:,:,ctr),colormap)
            title(['Interpolated Slice ' num2str(ctr-1) ])
    end
        subplot(1,size(InterpolatedImageStack,3),size(InterpolatedImageStack,3))
        imshow(InterpolatedImageStack(:,:,size(InterpolatedImageStack,3)),colormap)
        title(['Original Slice 2'])