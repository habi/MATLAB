close all;
clear;
clc;

%Input = rand(128,128);
Input = phantom(256);
height=size(Input,2);
width=size(Input,1);
Input=Input(:,floor(width/3)+1:floor(2*width/3));

height=size(Input,2);
width=size(Input,1);
oddrows  = 1:2:size(Input,1);
meanrows = 2:2:size(Input,1);
steps = 1:1:size(Input,1);

Mask = Input;
Mask(1:2:size(Input,1),:) = NaN;

Output = [];

for i = 1:height,
    % interpolate the odd rows
    Output(:,i) = interp1(oddrows,Input(oddrows,i),steps); 
end
%Output(:,:)=Input(1:2:size(Input,1),:);

screensize = get(0,'ScreenSize');
%ScreenSize is a four-element vector: [left, bottom, width, height]
figure('Position',[000 screensize(4)/3 screensize(3)/3 screensize(4)/3]);
colormap gray;
imagesc(Input);
title('input');

figure('Position',[200 screensize(4)/3 screensize(3)/3 screensize(4)/3]);
colormap gray;
imagesc(Mask);
title('mask');

figure('Position',[400 screensize(4)/3 screensize(3)/3 screensize(4)/3]);
colormap gray;
imagesc(Output);
title('output');