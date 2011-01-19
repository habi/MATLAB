%% CUTLINE FINDER
% attempts to find the cutlines between two input images
% first version 12.02.2010
clc;clear all;close all;

ProjectionNumber = 1213;

%% Loading Images
Tmp = double(imread('C:\Documents and Settings\haberthuer\Desktop\21Bb\DarkImage.tif'));
Dark(:,:,1) = Tmp;
Dark(:,:,2) = Tmp;
Dark(:,:,3) = Tmp;

Tmp = double(imread('C:\Documents and Settings\haberthuer\Desktop\21Bb\FlatImage.tif'));
Flat(:,:,1) = Tmp;
Flat(:,:,2) = Tmp;
Flat(:,:,3) = Tmp;
clear Tmp

Projection(:,:,1) = double(imread([ ...
    'C:\Documents and Settings\haberthuer\Desktop\21Bb\' ...
    'R108C21Bb_s1' sprintf('%04d',ProjectionNumber) ...
    '.tif' ]));
Projection(:,:,2) = double(imread([ ...
    'C:\Documents and Settings\haberthuer\Desktop\21Bb\' ...
    'R108C21Bb_s2' sprintf('%04d',ProjectionNumber) ...
    '.tif' ]));
Projection(:,:,3) = double(imread([ ...
    'C:\Documents and Settings\haberthuer\Desktop\21Bb\' ...
    'R108C21Bb_s3' sprintf('%04d',ProjectionNumber) ...
    '.tif' ]));

CorrProjection = -log(( Projection - Dark ) ./ Flat);

%% Displaying Images
figure
    subplot(3,3,1)
        imshow(Dark(:,:,1),[])
        title('Dark')
	subplot(3,3,2)
        imshow(Flat(:,:,1),[])
        title('Flat')
    subplot(334)
        imshow(Projection(:,:,1),[])
        title(['SubScan s_1, Proj ' num2str(ProjectionNumber) ])
    subplot(335)
        imshow(Projection(:,:,2),[])
        title(['SubScan s_2, Proj ' num2str(ProjectionNumber) ])
    subplot(336)
        imshow(Projection(:,:,3),[])
        title(['SubScan s_3, Proj ' num2str(ProjectionNumber) ])     
    subplot(337)
        imshow(CorrProjection(:,:,1),[])
        title(['SubScan s_1, Corrected Proj ' num2str(ProjectionNumber) ])
    subplot(338)
        imshow(CorrProjection(:,:,2),[])
        title(['SubScan s_2, Corrected Proj ' num2str(ProjectionNumber) ])
    subplot(339)
        imshow(CorrProjection(:,:,2),[])
        title(['SubScan s_3, Corrected Proj ' num2str(ProjectionNumber) ])
       
%% Cutline Extraction        
calculatecutline = 0;
if calculatecutline == 0
    overlapold12 = 73;
	overlapold23 = 65;
    overlapnew12 = 73;
    overlapnew23 = 65;
else
    overlapold12 = function_cutline(CorrProjection(:,:,1),CorrProjection(:,:,2));
	overlapold23 = function_cutline(CorrProjection(:,:,2),CorrProjection(:,:,3));
    overlapnew12 = find_overlap(CorrProjection(:,:,1),CorrProjection(:,:,2),128,2);
    overlapnew23 = find_overlap(CorrProjection(:,:,2),CorrProjection(:,:,3),128,2);

    disp([ 'The `old` cutline is between s_1 and s_2 is ' num2str(overlapold12) ', the `new` one is ' num2str(overlapnew12) '.' ])
    disp([ 'The `old` cutline is between s_2 and s_3 is ' num2str(overlapold23) ', the `new` one is ' num2str(overlapnew23) '.' ])
end

%% Merging
MergedProjection = [ CorrProjection(:,1:end-overlapold12-1,1) ... % - (mean(mean(mean(CorrProjection)))/3) ...
    CorrProjection(:,:,2) ...
    CorrProjection(:,overlapold23+1:end,3) ... % + (mean(mean(mean(CorrProjection)))/3) ...
    ];

%% Display Merged Image
figure
    subplot(231)
    	imshow(CorrProjection(:,:,1),[])
        title(['SubScan s_1, Corrected Proj ' num2str(ProjectionNumber) ])
        hold on
        plot(size(Projection,1)-overlapold12,1:size(Projection,1)-1,'Color','g')
    subplot(232)
    	imshow(CorrProjection(:,:,2),[])
        title(['SubScan s_2, Corrected Proj ' num2str(ProjectionNumber) ])
    subplot(233)
    	imshow(CorrProjection(:,:,3),[])
        title(['SubScan s_3, Corrected Proj ' num2str(ProjectionNumber) ])
        hold on
        plot(overlapold23,1:size(Projection,1)-1,'Color','r')
     subplot(2,3,4:6)
     	imshow(MergedProjection,[])
        title('Merged Subscans (with altered Brightness to make seams visible...)')