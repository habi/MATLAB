%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helperscript to find the "Overlap" between several stacked scans. Since
% Xtris' Script has a small overlap and we don't correct for it, we need to
% generate a "new" stack, or we have some slices two times in the stacked
% stack (Bottom slices from top stack are the same as top slices from
% bottom stack)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;clear all;close all;tic;
warning off Images:initSize:adjustingMag % suppress the warning about big images, they are still displayed correctly, just a bit smaller..

%% Setup
Drive = 'R';        % Setup for Windows
ReadHowMany = 100;   % How many slices should we read from the top of stack N+1 to match with stack N
ScaleTo = 512;      % Rescale Images to this size for faster calculation 

%% Do not change this
StackFound = 1;     % Parameter used to stop execution of program if we haven't got 1024 or 2048 slices

%% Ask the User what SubScans we should merge
h=helpdlg('Select the directory of the first scan (B1) of the stack you want to assess the vertical overlap. Select the top directory, do NOT select the tif- or rec-Directory!');
uiwait(h);
pause(0.01);
if isunix==0
    StartPath = [ Drive ':' filesep 'SLS' filesep '2010c' filesep];
else
    StartPath = [ filesep 'sls' filesep 'X02DA' filesep 'data' filesep 'e11126' ];
   
end

disp(['Opening ' StartPath ' to look for top stack'])
[ SampleDirectory SampleName ] = fileparts(uigetdir(StartPath, 'Pick a Directory'));
[ SampleBaseName Starting Ending] = regexp(SampleName, 'B1', 'match', 'start', 'end');

disp(['The BaseName for the Samples is: ' SampleName(1:Starting) 'X' SampleName(Ending+1:end)])
disp('---')

%% See how many Stacks we're dealing with...
for i=1:10
    CurrentSampleName = [SampleName(1:Starting) num2str(i) SampleName(Ending+1:end)];
    disp(['Looking for Stack ' CurrentSampleName])
    if exist([SampleDirectory filesep CurrentSampleName],'dir')~=7 % check if Directory exists
        AmountOfStacks = i-1; % decrease Count if Directory doesn't exist
        disp([ CurrentSampleName ' not found -> we have ' ...
            num2str(AmountOfStacks) ' vertical Stacks to deal with'])
        break
    end
end
Stack(AmountOfStacks).SampleName = NaN; % Preallocate "Stacks" for speed reasons
disp('---')

%% Read Images from Top and Bottom, where necessary
w = waitbar(0,'Loading Images, Please wait');
WaitCounter = 0;
for i=1:AmountOfStacks
    disp([ 'Working on Stack ' num2str(i) '/' num2str(AmountOfStacks) ])
    Stack(i).SampleName = [SampleName(1:Starting) num2str(i) SampleName(Ending+1:end)];
    FilePrefix = [SampleDirectory filesep Stack(i).SampleName filesep 'rec_8bit' filesep Stack(i).SampleName ];
    %% Load TOP Images
    for k = 1:ReadHowMany
        if i~=1 % don't load TOP image for first stack
            disp([ Stack(i).SampleName ': loading top image ' num2str(k) '/' num2str(ReadHowMany) ])
            Stack(i).TopImages(:,:,k) = imresize(imread([ FilePrefix sprintf('%04d',k) '.rec.8bit.tif' ]),[ScaleTo NaN]);
        end
        WaitCounter = WaitCounter + 1;
        waitbar(WaitCounter/(ReadHowMany*AmountOfStacks),w);
    end
    %% Load TOP Images
    %% Load BOTTOM Images
    disp([ Stack(i).SampleName ': loading last image' ])
    if i~=AmountOfStacks % don't load BOTTOM image for last stack
        try
            try
                FileNumber = 2048;
                Stack(i).BottomImage = imresize(imread([ FilePrefix sprintf('%04d',FileNumber) '.rec.8bit.tif' ]),[ScaleTo NaN]);
            catch Only1024
                FileNumber = 1024;
                Stack(i).BottomImage = imresize(imread([ FilePrefix sprintf('%04d',FileNumber) '.rec.8bit.tif' ]),[ScaleTo NaN]);
            end
        catch Not1024NOr2048
            disp('We could not find File 1024 or 2048. Do we have a full stack?')
            StackFound = 0;
            break
        end
    end
	%% Load BOTTOM Images
    disp('---')
end
close(w)

if StackFound == 0 % Break program exectution if we haven't found file 1024 or 2048 for the Stacks...
    break
end

%% Calculate Results
for i=2:AmountOfStacks
    % Look in top Images of second, third, ... stack for minimal difference to
    % bottom images of first, second, ... stack
    for k=1:ReadHowMany
        Stack(i).DifferenceImage(:,:,k)=imabsdiff(Stack(i-1).BottomImage,Stack(i).TopImages(:,:,k));
        Stack(i).Difference(k)=sum(sum(Stack(i).DifferenceImage(:,:,k)));
    end
    %% Find Minima
    [ TMP Stack(i).SliceNumberOfSliceWithMinimalDifference ] = min(Stack(i).Difference);
    disp(['Found Slice Nr. ' num2str(Stack(i).SliceNumberOfSliceWithMinimalDifference) ...
        ' of Stack B' num2str(i) ' to be the best match to the last slice of Stack B' ...
        num2str(i-1) ])
    Stack(i).SliceWithMinimalDifference = Stack(i).TopImages(:,:,Stack(i).SliceNumberOfSliceWithMinimalDifference);
end

%% Display Results to user and finish
figure(1)
    for i=2:AmountOfStacks
        subplot(3,AmountOfStacks,i)
            plot(Stack(i).Difference/max(Stack(i).Difference))
            title([ 'Difference(Bottom(B' num2str(i-1) '),Top(B' num2str(i) '))' ])
    end
    for i=2:AmountOfStacks
        subplot(3,AmountOfStacks,i+AmountOfStacks)
            imshow(Stack(i).SliceWithMinimalDifference,[])
            title(['B' num2str(i) ', best match (Img. ' num2str(Stack(i).SliceNumberOfSliceWithMinimalDifference) ')'])
    end
    for i=1:AmountOfStacks-1
        subplot(3,AmountOfStacks,i+2*AmountOfStacks)
            imshow(Stack(i).BottomImage,[])
            title(['B' num2str(i) ', bottom (Img. ' num2str(FileNumber) ')'])
    end

disp('---')
disp('To have a nice total stack for further processing, use')
for i=1:AmountOfStacks
    if isempty(Stack(i).SliceNumberOfSliceWithMinimalDifference)
        disp(['Slices 1:' num2str(FileNumber) ' of ' SampleDirectory filesep Stack(i).SampleName ])
    else
        disp(['Slices ' num2str(Stack(i).SliceNumberOfSliceWithMinimalDifference+1) ...
            ':' num2str(FileNumber) ' of ' SampleDirectory filesep Stack(i).SampleName ])
    end
end