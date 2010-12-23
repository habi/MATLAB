clc
clear
close all
warning off Images:initSize:adjustingMag % suppress the warning about big images, they are still displayed correctly, just a bit smaller..

ImageSize = 1024
DetectorSize = 256
GivenOverlap = 128 % in pixels
image = phantom(ImageSize);
%image = rand(ImageSize);
%image = imresize(radon(Phantom(ImageSize)), [ImageSize ImageSize]);

NumSubScans = ceil ( ImageSize / ( DetectorSize - GivenOverlap ))
SliceStart = 1
SliceWidth = DetectorSize - GivenOverlap

if NumSubScans * SliceWidth + GivenOverlap  - ImageSize >= DetectorSize
    Reduce = floor(( NumSubScans * SliceWidth + GivenOverlap  - ImageSize ) / DetectorSize);
    blocks = blocks - reduce ;
end
if NumSubScans * SliceWidth + GivenOverlap > ImageSize
    EnlargePixels = NumSubScans * SliceWidth + GivenOverlap - ImageSize;
    image = [ image zeros(size(image,2),EnlargePixels) ];
end

%% Subscans
disp('Slicing and dicing')
for n = 1:NumSubScans
    SliceData(n)= struct('SubScans',image(:,SliceStart:SliceStart + DetectorSize - 1));
    SliceStart = SliceStart + SliceWidth;
end

%% Concatenating the SubScans without overlap
disp('Concatenating Images') % with artificial Borders!')
ConcatenatedImage =  [];
for n = 1:NumSubScans
    ConcatenatedImage = [ConcatenatedImage SliceData(n).SubScans ]; % rand(ImageSize,10) ];
end

%% Merging Images
disp('Merging Images')
MergedImage = [];
% calculate Overlap
for n=1:NumSubScans
    Overlap(n) = GivenOverlap;
end

for n=1:NumSubScans-1
    figure % #51
    ImageDifference = 0;
    shiftrange = 1:DetectorSize;
    for shift = shiftrange
        EmptySlice1  = zeros(ImageSize,DetectorSize-shift);
        EmptySlice2 = zeros(ImageSize,shift);
        Img1 = [ EmptySlice1 SliceData(n+1).SubScans EmptySlice2 ];
        Img2 = [ EmptySlice2 SliceData(n).SubScans EmptySlice1 ];
        DiffImg = Img1 .* Img2;
        ImageDifference = mean(mean(DiffImg));
        plotdiff(shift) = ImageDifference;
        subplot(131)
            imshow(Img1,[])
        subplot(132)
            imshow(DiffImg,[]);
            title(num2str(ImageDifference))
        subplot(133)
            imshow(Img2,[])
        pause(0.001)
    end
    figure
        plot(plotdiff(shiftrange))
end
for n=1:NumSubScans
    MergedImage = [ MergedImage SliceData(n).SubScans(:,1:size(SliceData(n).SubScans,2) - Overlap(n)) ];
end

%% showing the images
disp('showing the Images')
figure('name','Phantom')
    imshow(image,[])
    axis on
figure('name','SubScans')
    for n=1:NumSubScans
        subplot(1,NumSubScans,n)
            imagesc(SliceData(n).SubScans)
            axis on
            colorbar('NorthOutside')
            if n < NumSubScans
                title([ 'image ' num2str(n)] )
            elseif n == NumSubScans
                title([ 'enlarged image ' num2str(n) ] )
            end
    end
figure('name','Concatenated Images')
    imshow(ConcatenatedImage,[])
    axis on
figure('name','Merged Images')
    imshow(MergedImage,[])
    axis on
    
disp('I`m done with all you`ve asked for...')
helpdlg('I`m done with all you`ve asked for...','Phew!');    