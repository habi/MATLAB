function InterpolatedImage = h_SplitInterpolate(InputImage,DetectorWidth)
% the InputImage is split in 'AmountofSlabs' parts, in the middle part, the
% image is interpolated from every fourth line, in the parts adjacent, from
% every second line.

% %-------------Test-----------
% clc;
% clear;
% close all;
% InputImage=phantom(256);
% %InputImage = double(imread('/afs/psi.ch/user/h/haberthuer/images/phantom512.png','png'));
% DetectorWidth = 65;
% %-------------Test-----------


InputImage = InputImage';
InputImageMaxWidth = ceil( sqrt( size(InputImage,1)^2 + size(InputImage,2)^2 ) ) ;
if rem(InputImageMaxWidth,2)
    InputImageMaxWidth = InputImageMaxWidth +1;
end
RingsSlabs = h_HowManyRings(InputImageMaxWidth,DetectorWidth);
TotalRings = RingsSlabs(1);
TotalSlabs = RingsSlabs(2);
Interpolate = ones(1,TotalSlabs);
ImageWidth = size(InputImage,2);
SlabWidth = ceil( ImageWidth / TotalSlabs );

%% set stuff for Calculation
InterpolatedImage = InputImage; % set `baseline` image
%IterpolatedImage = h_PadImage(InterpolatedImage,ImageWidth,InputImageMaxWidth);
AllRows = 1:1:size(InputImage,1);
currentSlab = ceil(TotalSlabs/2);

%% Calculate and set Output
for currentRing=0:TotalRings
    Input = input(['Enter Interpolation for Ring ' num2str(currentRing) '/Slab ' num2str(currentSlab) ...
        '. (Enter a number number or just press `Enter` for no interpolation)']);
    if isempty(Input)
        Input = 1;
    end
    Interpolate(currentSlab) = Input;
    if currentRing > 3
        disp('more than 3 rings are not done yet...')
        break
    end
    if currentRing == 3;
       % disp('currentring=3')
        InterpolateRows = Interpolate(currentSlab);
        RowsToInterpolate  = 1:InterpolateRows:size(InputImage,1);
       % SlabWidth = ceil( ImageWidth / TotalSlabs );
        LeftSlabCenter = size(InputImage,1)/2-currentRing*SlabWidth;
        if LeftSlabCenter < (SlabWidth /2)
            break
        end
        RightSlabCenter = size(InputImage,1)/2+currentRing*SlabWidth;
        InterpolatedImage(:,floor(LeftSlabCenter-floor(SlabWidth/2))+1:floor(LeftSlabCenter+floor(SlabWidth/2))+1) = ...
            interp1(RowsToInterpolate,...
            InterpolatedImage(RowsToInterpolate,floor(LeftSlabCenter-floor(SlabWidth/2))+1:floor(LeftSlabCenter+floor(SlabWidth/2))+1),...
            AllRows,'linear','extrap');
        InterpolatedImage(:,floor(RightSlabCenter-floor(SlabWidth/2))-1:floor(RightSlabCenter+floor(SlabWidth/2))-1) = ...
            interp1(RowsToInterpolate,...
            InterpolatedImage(RowsToInterpolate,floor(RightSlabCenter-floor(SlabWidth/2))-1:floor(RightSlabCenter+floor(SlabWidth/2))-1),...
            AllRows,'linear','extrap');
        currentRing = currentRing+1;
        currentSlab = currentSlab+1;
    end
    if currentRing == 2;
       % disp('currentring=2')
        InterpolateRows = Interpolate(currentSlab);
        RowsToInterpolate  = 1:InterpolateRows:size(InputImage,1);
       % SlabWidth = ceil( ImageWidth / TotalSlabs );
        LeftSlabCenter = size(InputImage,1)/2-currentRing*SlabWidth;
        if LeftSlabCenter < (SlabWidth /2)
            break
        end
        RightSlabCenter = size(InputImage,1)/2+currentRing*SlabWidth;
        InterpolatedImage(:,floor(LeftSlabCenter-floor(SlabWidth/2))+1:floor(LeftSlabCenter+floor(SlabWidth/2))+1) = ...
            interp1(RowsToInterpolate,...
            InterpolatedImage(RowsToInterpolate,floor(LeftSlabCenter-floor(SlabWidth/2))+1:floor(LeftSlabCenter+floor(SlabWidth/2))+1),...
            AllRows,'linear','extrap');
        InterpolatedImage(:,floor(RightSlabCenter-floor(SlabWidth/2))-1:floor(RightSlabCenter+floor(SlabWidth/2))-1) = ...
            interp1(RowsToInterpolate,...
            InterpolatedImage(RowsToInterpolate,floor(RightSlabCenter-floor(SlabWidth/2))-1:floor(RightSlabCenter+floor(SlabWidth/2))-1),...
            AllRows,'linear','extrap');
        currentRing = currentRing+1;
        currentSlab = currentSlab+1;
    end
    if currentRing == 1;
       % disp('currentring=1')
        InterpolateRows = Interpolate(currentSlab);
        RowsToInterpolate  = 1:InterpolateRows:size(InputImage,1);
        SlabWidth = ceil( ImageWidth / TotalSlabs );
        LeftSlabCenter = size(InputImage,1)/2-currentRing*SlabWidth;
        RightSlabCenter = size(InputImage,1)/2+currentRing*SlabWidth;
        if LeftSlabCenter < (SlabWidth /2)
            break
        end
        InterpolatedImage(:,floor(LeftSlabCenter-floor(SlabWidth/2))+1:floor(LeftSlabCenter+floor(SlabWidth/2))+1) = ...
            interp1(RowsToInterpolate,...
            InterpolatedImage(RowsToInterpolate,floor(LeftSlabCenter-floor(SlabWidth/2))+1:floor(LeftSlabCenter+floor(SlabWidth/2))+1),...
            AllRows,'linear','extrap');
        InterpolatedImage(:,floor(RightSlabCenter-floor(SlabWidth/2))-1:floor(RightSlabCenter+floor(SlabWidth/2))-1) = ...
            interp1(RowsToInterpolate,...
            InterpolatedImage(RowsToInterpolate,floor(RightSlabCenter-floor(SlabWidth/2))-1:floor(RightSlabCenter+floor(SlabWidth/2))-1),...
            AllRows,'linear','extrap');
        currentRing = currentRing+1;
        currentSlab = currentSlab+1;
    end
    if currentRing == 0;
      % disp('currentring=0')
        currentSlab = ceil(TotalSlabs/2);
        InterpolateRows = Interpolate(currentSlab);
        RowsToInterpolate  = 1:InterpolateRows:size(InputImage,1);
        %SlabWidth = floor( SlabWidth /2 );
        SlabCenter = ceil(size(InputImage,1)/2);
        InterpolatedImage(:,floor(SlabCenter-SlabWidth/2):floor(SlabCenter+SlabWidth/2)) = ...
        interp1(RowsToInterpolate,...
        InterpolatedImage(RowsToInterpolate,floor(SlabCenter-SlabWidth/2):floor(SlabCenter+SlabWidth/2)),...
        AllRows,'linear','extrap');
        currentRing = currentRing+1;
        currentSlab = currentSlab+1;
    end
end
% 
% % %-------------Test-----------
% figure;
% subplot(121);
% colormap gray;
% imagesc(InputImage);
% title('Input');
% axis image;
% subplot(122);
% colormap gray;
% imagesc(InterpolatedImage);
% title(['Output (' num2str(TotalRings) ' ring(s) (plus the center!))']);
% axis image;
% % %-------------Test-----------

end