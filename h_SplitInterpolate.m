%function Output = h_SplitInterpolate(Input,AmountofSlabs,SplitRows)
% takes input image and splits it in 'Split' parts. Every 'SplitRows' of
% the middle part is interpolated from the rest of the middle row.
% Split and SplitRows are just dummy operators for now!
% the Sinogram is split in 3 parts, and in the middle part every second row
% is interpolated


% %-------------Test-----------
clc;
clear;
close all;
Input=phantom(128);
%Input = double(imread('/afs/psi.ch/user/h/haberthuer/images/phantom512.png','png'));
AmountofSlabs = 3;
% %-------------Test-----------

Input = Input'; % used, since MATLAB makes the Sinograms rotated to what we know and like
Original = Input;

height=size(Original,1);
width=size(Original,2);
steps=1:1:size(Original,1);

slabheight=size(Input,1);
slabwidth=size(Input,2);
oddrows  = 1:2:size(Input,1);
meanrows = 2:2:size(Input,1);
steps = 1:1:size(Input,1);












%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if AmountofSlabs == 3
    InputLeft   = Input(:,1:floor(width/3));
    InputMiddle = Input(:,floor(width/3)+1:floor(2*width/3));
    InputRight  = Input(:,floor(2*width/3)+1:width);

    Input = InputMiddle;
    InputMiddle = [];
     
    slabheight=size(Input,1);
    slabwidth=size(Input,2);
    oddrows  = 1:2:size(Input,1);
    meanrows = 2:2:size(Input,1);
    steps = 1:1:size(Input,1);
    
    for i = 1:slabwidth,
    % interpolate the odd rows 
        InputMiddle(oddrows,i) = Input(oddrows,i);
        InputMiddle(meanrows,i) = NaN;
%         InputMiddle(:,i) = interp1(oddrows,Input(oddrows,i),steps,'linear','extrap'); 
    end

    Output = [InputLeft'; InputMiddle'; InputRight']; 
    Output = Output';    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if AmountofSlabs == 5
    InputLefter  = Input(:,1:floor(width/5));
    InputLeft    = Input(:,floor(width/5)+1:floor(2*width/5));
    InputMiddle  = Input(:,floor(2*width/5)+1:floor(3*width/5));
    InputRight   = Input(:,floor(3*width/5)+1:floor(4*width/5));
    InputRighter = Input(:,floor(4*width/5)+1:width);
    
  
    Output = [InputLefter'; InputLeft'; InputMiddle'; InputRight'; InputRighter']; 
    Output = Output';
 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if AmountofSlabs == 7
    InputLeftest  = Input(:,1:floor(width/7));
    InputLefter   = Input(:,floor(width/7)+1:floor(2*width/7));
    InputLeft     = Input(:,floor(2*width/7)+1:floor(3*width/7));
    InputMiddle   = Input(:,floor(3*width/7)+1:floor(4*width/7));
    InputRight    = Input(:,floor(4*width/7)+1:floor(5*width/7));
    InputRighter  = Input(:,floor(5*width/7)+1:floor(6*width/7));
    InputRightest = Input(:,floor(6*width/7)+1:width);
    
    
    Output = [InputLeftest'; InputLefter'; InputLeft'; InputMiddle'; InputRight'; InputRighter'; InputRightest']; 
    Output = Output';
 
end


% for count=1:AmountofSlabs
%     a = (count-1)*round(width/AmountofSlabs)+1
%     b = (count)*round(width/AmountofSlabs)
%     
%     Calc = Input;
%     %Calc(:,count*a:count*b) = Input(:,count*a:count*b);
%     
%     disp(['Count=' num2str(count) ', Width=' num2str(floor(count*(width/AmountofSlabs)))])
%     count=count+1;
% end




% %-------------Test-----------
screensize = get(0,'ScreenSize');
figure('Position',[8*screensize(4)/10 screensize(4)/10 screensize(3)/3 screensize(4)/3]);
subplot(1,2,1);
imagesc(Original);
title('original');
axis equal tight;
subplot(1,2,2);
imagesc(Output);
title('middle is interpolated');
axis equal tight;

% figure('Position',[5*screensize(4)/10 screensize(4)/10 screensize(3)/3 screensize(4)/3]);
% imagesc(Calc);
% axis equal tight;
% Output the sizes, if necessary for control
Inputsize = size(Original)
Outputsize = size(Output)
Phantomwidth = width
SlabWidth = width/AmountofSlabs
% %-------------Test-----------

%end