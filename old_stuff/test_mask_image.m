close all;
clear;
clc;

%Input = rand(12,12);
Input = phantom(256);

oddrows  = 1:2:size(Input,1);
meanrows = 0:2:size(Input,1);

steps=1:1:size(Input,1);

Mask(1:2:size(Input,1),:) = NaN;

for i = 1:size(Input,1),
    % interpolate the odd rows
    Mask(oddrows,i) = Input(oddrows,i); 
    Output(:,i) = [interp1(oddrows,[Input(oddrows,i)]',steps)]'; 
end
%Output(:,:)=Input(1:2:size(Input,1),:);

screensize = get(0,'ScreenSize');
%ScreenSize is a four-element vector: [left, bottom, width, height]
figure('Position',[20 screensize(4)/3 screensize(3)/3 screensize(4)/3])

subplot(2,2,[1,2]);
imshow(Input);
title('input');

subplot(2,2,3);
imshow(Mask);
title('mask');

subplot(2,2,4);
imshow(Output);
title('output');