function InterpolateImage = h_SplitInterpolate(InputImage,AmountofSlabs,Middle,Ring)
% the InputImage is split in 'AmountofSlabs' parts, in the middle part, the
% image is interpolated from every `Middle` line, in the parts adjacent, from
% every `Ring` line.

% %-------------Test-----------
% clc;
% clear;
% close all;
% InputImage=phantom(1024);
% %InputImage = double(imread('/afs/psi.ch/user/h/haberthuer/images/phantom512.png','png'));
% AmountofSlabs = 5;
% Middle = 10;
% Ring = 5;
% InputImage = InputImage';
% tic;
% %-------------Test-----------

InputImage = InputImage';

if mod(AmountofSlabs/2,1) == 0
    disp(['Error: The amount of slabs has to be an odd number or else I'...
        ' cannot compute what you told me!'])
    return
end

AmountofRings = floor ( AmountofSlabs / 2 );
OutputImage = InputImage; % save it for later
InterpolateImage = InputImage; % copy input > interpolate

ImageWidth = size(InputImage,2);
SlabWidth = floor(ImageWidth / AmountofSlabs);
Overshoot = SlabWidth * AmountofSlabs - ImageWidth;

currentring = AmountofRings;
AllRows = 1:1:size(InputImage,1);
    
for count=1:AmountofSlabs
    if currentring == 0
        RowsToInterpolate  = 1:Middle:size(InputImage,1);
    end
    if currentring == 1
        RowsToInterpolate  = 1:Ring:size(InputImage,1);
    end
    if currentring > 1
        RowsToInterpolate  = 1:1:size(InputImage,1);
    end
    currentSlab = count;
    InterpolateImage(:,((count-1)*SlabWidth)+1:count*SlabWidth) = ...
       InputImage(:,((count-1)*SlabWidth)+1:count*SlabWidth);
    for i = 1:SlabWidth
        InterpolateImage(:,((count-1)*SlabWidth)+1:count*SlabWidth) = ... 
        interp1(RowsToInterpolate,InterpolateImage(RowsToInterpolate,((count-1)*SlabWidth)+1:count*SlabWidth),AllRows,'linear','extrap'); 
    end
    % check at which ring we are
%     disp(['current slab: ' num2str(currentSlab) ...
%         '/current ring: ' num2str(currentring)]);
    if currentSlab < AmountofRings
        currentring = currentring -1;
    end
    if currentSlab == AmountofRings
        currentring = 0;
    end
    if currentSlab > AmountofRings
        currentring = currentring +1;
    end
    count = count +1;
end

InterpolateImage = InterpolateImage';

% %-------------Test-----------
% for linecounter=1:AmountofSlabs-1
%         InterpolateImage(linecounter*floor(size(InterpolateImage,1)/AmountofSlabs),:) = max(max(InterpolateImage));
% end
% InterpolateImage = InterpolateImage';    
% figure;
% subplot(1,2,1);
% %colormap gray;
% imagesc(InputImage);
% title('Input');
% axis equal tight;
% subplot(1,2,2);
% %colormap gray;
% imagesc(InterpolateImage);
% title(['Output (' num2str(AmountofSlabs) ' slabs)']);
% axis equal tight;
% 
% Inputsize = size(InputImage)
% Outputsize = size(OutputImage)
% AmountofSlabs = AmountofSlabs
% 
% toc
% %-------------Test-----------

end