%% Clear Workspace
clear;
clc;
close all;
tic; % start timer

%% set parameters
resize = .5;
slabs = 3;               % in how many slabs should the sinogram be splitted?

ownphantom = 0;          % use my own phantom =1, use MATLAB phantom = 0
writefigures = 1;        % save figures to disk
writeimages = 0;         % save only the images to disk (no captions!)
protocols=['b' 'c' 'd' 'e' 'f'];

whichone =  protocols(5);   % b, c, d oder so...
Verh                = 3;    %Verhaeltnis zum Soll
CenterInterpolate   = 1;    % what's the desired interpolation in the middle? 
RingInterpolate     = 1;    % what's the desired interpolation in the ring?


% generally, there is no need to edit stuff below this line
% ---------------------------------------------------------

%% Initialization
stepcounter = 1;
if ownphantom ==1
    Phantom = double(imread('/afs/psi.ch/user/h/haberthuer/images/phantom512.png','png'));
%    Phantom = double(imread('/afs/psi.ch/user/h/haberthuer/images/slice.png','png'));
else
    Phantom = phantom(512);
end

if resize == 1
else
    Phantom = imresize(Phantom,resize); % resize input image to a smaller size > faster calculations for testing...
end
Phantom = Phantom ./ max(max(Phantom));

Proj = ceil(sqrt(2)*size(Phantom,1)); 
numproj = Proj/2; % proj pro 180
anglestep = Verh*180/(numproj-1);

disp(['The Phantom is ' num2str(size(Phantom,1)) ' x ' num2str(size(Phantom,2)) ' px big (a'...
      ' diagonal of ' num2str(Proj) ' px).']);
disp(['If we want to have ' num2str(slabs) ' slabs, the `Detector` is thus assumed to be '...
       num2str(ceil(Proj / slabs)) ' px wide...']);

theta=0:anglestep:180;
Sinogram = radon(Phantom,theta); % calculate the sinograms

OriginalSinogram = Sinogram; % store them for output at the end...
OriginalSinogram = OriginalSinogram ./ max(max(OriginalSinogram));

% interpolate the middle of the Sinograms
Sinogram = h_SlabInterpolate(Sinogram,slabs,CenterInterpolate,RingInterpolate); 
Sinogram = Sinogram ./ max(max(Sinogram));

% calculate the reconstructions, once for the resamples/interpolated
% Sinogram, and once for the original ones as a reference.
Reconstruction = iradon(Sinogram,theta); % calculate the inverse
Reconstruction = Reconstruction ./ max(max(Reconstruction));

OriginalReconstruction = iradon(OriginalSinogram,theta); % calculate the inverse
OriginalReconstruction=OriginalReconstruction ./ max(max(OriginalReconstruction)); 
    
for linecounter=1:slabs-1
    Sinogram(linecounter*floor(size(Sinogram,1)/slabs),:) = max(max(Sinogram));
end
   
% Calculate Error in the Images
BigPhantom = h_PadImage(Phantom,max(size(Phantom)),max(size(Reconstruction)));
BigPhantom = BigPhantom ./ max(max(BigPhantom));

ErrorImage = BigPhantom;
ErrorOriginalImage = BigPhantom;
ErrorBetweenReconstructions = BigPhantom;
pixels = size(BigPhantom,1) * size(BigPhantom,2);
    
ErrorImage = ( single(BigPhantom) - single(Reconstruction) ).^2 ;
quadError(stepcounter) = sum( sum( ErrorImage ) );
 
ErrorOriginalImage = ( single(BigPhantom) - single(OriginalReconstruction) ).^2 ;
quadOriginalError(stepcounter) = sum( sum( ErrorOriginalImage ) );
    
ErrorBetweenReconstructions = ( single(Reconstruction) - single(OriginalReconstruction) ).^2 ;
quadBetweenReconstructionsError(stepcounter) = sum( sum( ErrorBetweenReconstructions ) );

  
%% Display
figure(1);
    subplot(1,2,1)
    colormap gray;
    imagesc(Sinogram');
    axis image;
    title({['Protocol ' num2str(whichone) ': Interpolated Sinograms'];...
           ['with (approx.!) overlayed slabs (' num2str(slabs) ')'];...
           ['center slab interpolated from every ' num2str(CenterInterpolate) '. line,'];...
           ['first ring interpolated from every ' num2str(RingInterpolate) '. line.']});        
    subplot(1,2,2)
    colormap gray;
    imagesc(OriginalSinogram');
    axis image;
    title({['Protocol ' num2str(whichone) ': Original Sinograms'];...
           ['Phantom Size is ' num2str(size(Phantom))]});
    if writefigures == 1
        print('-dpng', [num2str(whichone) '-sinograms']);
        close;
    else
    end
    
figure(2);
    colormap gray;
    imagesc(Phantom);
    axis image;
    title(['Protocol ' num2str(whichone) ': Phantom']);
    if writefigures == 1
        print('-dpng', [num2str(whichone) '-phantom']);
        close;
    else
    end

figure(3);
    colormap gray;
    imagesc(Reconstruction);
    axis image;  
    title({['Protocol ' num2str(whichone) ': Reconstruction with interpolated Sinogram (' num2str(size(Sinogram)) ')'];...
           ['center interpolated from every ' num2str(CenterInterpolate) '. line,'];...
           ['first ring interpolated from every ' num2str(RingInterpolate) '. line.']});        
    if writefigures == 1
        print('-dpng', [num2str(whichone) '-reco-int']);
        close;
    else
    end
    
figure(4);
    colormap gray;
    imagesc(OriginalReconstruction);
    axis image;
    title(['Protocol ' num2str(whichone) ': Reconstruction with original Sinogram (' num2str(size(Sinogram)) ')']);
    if writefigures == 1
        print('-dpng', [num2str(whichone) '-reco-orig']);
        close;
    else
    end
 

 figure(5);
    colormap gray;
    imagesc(ErrorImage);
    axis image;
    title(['Protocol ' num2str(whichone) ': Error (Phantom-Reconstruction)']);
    if writefigures == 1
        print('-dpng', [num2str(whichone) '-error-phantom-recoint']);
        close;
    else
    end

figure(6);
    colormap gray;
    imagesc(ErrorOriginalImage);
    axis image;
    title(['Protocol ' num2str(whichone) ': Error (Phantom-OriginalReconstruction)']);
    if writefigures == 1
        print('-dpng', [num2str(whichone) '-error-phantom-recoorig']);
        close;
    else
    end
 
figure(7);
    colormap gray;
    imagesc(ErrorBetweenReconstructions);
    axis image;
    title(['Protocol ' num2str(whichone) ': Error between Reconstruction']);
    if writefigures == 1
        print('-dpng', [num2str(whichone) '-error-between']);
        close;
    else
    end
 
% output timing
toc