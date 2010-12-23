clear all;
close all;
clc

warning off Images:initSize:adjustingMag

% [ Filename1, pathname1] = ...
%      uigetfile({'*.jpg;*.tif;*.png;*.gif','All Img Files';...
%           '*.*','All Files' },'First Img'); 
% Name = sprintf('First file: %s',Filename1);
% [ Filename2, pathname2] = ...
%      uigetfile({'*.jpg;*.tif;*.png;*.gif','All Img Files';...
%           '*.*','All Files' },Name,pathname1); 

SampleName = 'R108C21A2m_S2';
slice = 1000;
interval = 1;

Filename1 = [ SampleName sprintf('%04d',slice) '.rec.8bit.tif' ];
Filename2 = [ SampleName sprintf('%04d',slice+interval) '.rec.8bit.tif' ];

Path = 'R:\SLS\2009f\R108C21A2m_S2\rec_8bit\';

Img1 = imread([Path Filename1]);
Threshold1 =graythresh(Img1);
Bitdepth1 = intmax(class(Img1));
disp([ num2str(Filename1) ' has been Thresholded with ' num2str(Threshold1) ' (' num2str(Bitdepth1*Threshold1) ')' ]);
Img2= imread([ Path Filename2 ]);
Threshold2 =graythresh(Img2);
Bitdepth2 = intmax(class(Img2));
disp([ num2str(Filename2) ' has been Thresholded with ' num2str(Threshold2) ' (' num2str(Bitdepth2*Threshold2) ')' ]);
if isequal(Bitdepth1,Bitdepth2) == 0
    disp(['Img 1 and Img 2 do not have the same bit depth (' class(Bitdepth1) ' vs. ' class(Bitdepth1) '). I am stopping here!'])
end

Img1_Thresh = im2bw(Img1,Threshold1);
Img1_Label = bwlabeln(Img1_Thresh);

Img2_Thresh = im2bw(Img2,Threshold2);
Img2_Label = bwlabeln(Img2_Thresh);

Img3 = im2double(Img2_Label);
imshow(Img3,[]);

DifferenceImage = ((Img1_Thresh - Img2_Thresh) + 1) /2;


%% Overlay Image
 
Color = [ 255 0 0 ] % define overlay colour RGB
 
ImgToOverlay = im2uint8(mat2gray(Img1)); % separate image into 3 channels
red = ImgToOverlay;
green = ImgToOverlay;
blue = ImgToOverlay;
 
red(Img1_Thresh) = Color(1);    % populate channels with thresholded image
green(Img1_Thresh) = Color(2);
blue(Img1_Thresh) = Color(3);
 
Overlay = cat(3, red, green, blue); % make RGB-image
 
figure % display everything
    subplot(131)
        imshow(Img1,[])
    subplot(132)
        imshow(DifferenceImage,[])    
    subplot(133)    
        imshow(Overlay,[])

break


%% Choose positive and negative Points on image

[xy_pos,xy_neg]=fct_SetPoints(image)