function Output = h_SplitInterpolate(Input,Split,SplitRows)
% takes input image and splits it in 'Split' parts. Every 'SplitRows' of
% the middle part is interpolated from the rest of the middle row.
% Split and SplitRows are just dummy operators for now!
% the Sinogram is split in 3 parts, and in the middle part every second row
% is interpolated


% %-------------Test-----------
% clc;
% clear;
% close all;
% Input=phantom(256);
% %Input = double(imread('/afs/psi.ch/user/h/haberthuer/images/phantom512.png','png'));
% Inputtmp = Input;
% %-------------Test-----------

Input = Input'; % used, since MATLAB makes the Sinograms rotated to what we know and like

height=size(Input,1);
width=size(Input,2);
steps=1:1:size(Input,1);

InputLeft=Input(:,1:floor(width/3));
InputMiddle=Input(:,floor(width/3)+1:floor(2*width/3));
InputRight=Input(:,floor(2*width/3)+1:width);

Input=InputMiddle;

height=size(Input,1);
width=size(Input,2);
oddrows  = 1:2:size(Input,1);
meanrows = 2:2:size(Input,1);
steps = 1:1:size(Input,1);

% Mask = Input;
% Mask(1:2:size(Input,1),:) = NaN;

InputMiddle = [];

for i = 1:width,
    % interpolate the odd rows
%     InputMiddle(oddrows,i) = Input(oddrows,i);
%     InputMiddle(meanrows,i) = NaN;
     
    InputMiddle(:,i) = interp1(oddrows,Input(oddrows,i),steps,'linear','extrap'); 
end

Output = [InputLeft'; InputMiddle'; InputRight']; 
%Output = Output';
size(Output);

Output = [InputLeft InputMiddle InputRight];


% %-------------Test-----------
% screensize = get(0,'ScreenSize');
% figure('Position',[20 screensize(4)/3 screensize(3)/3 screensize(4)/3]);
% subplot(1,2,1);
% imagesc(Inputtmp);
% title('original');
% axis equal;
% subplot(1,2,2);
% imagesc(Output);
% title('middle is interpolated');
% axis equal;
% 
% % Output the sizes, if necessary for control
% size(Input)
% size(Output)
% %-------------Test-----------

end