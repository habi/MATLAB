% Clear Workspace
clear;
clc;

% setup (base image and quality factor)
%Phantom = phantom(128);
Phantom = double(imread('/afs/psi.ch/user/h/haberthuer/images/phantom512.png','png'));
Phantom = imresize(Phantom,0.5,'bicubic'); % resize input image to a smaller size > faster calculations for testing...
quality = .3;

maxpixels = max(size(Phantom));  % get longest side of phantom
numprojections = maxpixels * quality; % number of projections to actually compute, weighted with quality

theta=[0:179/(numprojections-1):180]; % number of projections distributed over theta > altered with quality
%theta=[0:179]; % number of projections distributed over theta

% calculations 
Sinogram = radon(Phantom,theta); % calculate the sinograms
OriginalSinogram = Sinogram; % store them for output at the end...

Sinogram = h_SplitInterpolate(Sinogram,3,2); % 3 and 2 are just dummy operators for now!
Sinogram = Sinogram';

maxsizesino = size(Sinogram,2);
% Reconstruction = iradon(Sinogram,theta,'linear','Ram-Lak',1,maxsizesino); % calculate the inverse
Reconstruction = iradon(Sinogram,theta); % calculate the inverse
% OriginalReconstruction = iradon(OriginalSinogram,theta,'linear','Ram-Lak',1,maxsizesino); % calculate the inverse
OriginalReconstruction = iradon(OriginalSinogram,theta); % calculate the inverse

figure(1);
subplot(1,2,1)
colormap gray;
imagesc(Sinogram');
title(['Interpolated Sinograms, with Quality Factor= ' num2str(quality)]);
subplot(1,2,2)
colormap gray;
imagesc(OriginalSinogram');
title(['Original Sinograms, with Quality Factor= ' num2str(quality)]);

figure(2);
colormap gray;
imagesc(Phantom);
title('Original');

figure(3);
colormap gray;
imagesc(Reconstruction);
title(['Reconstruction with interpolated Sinogram  = ' num2str(size(Sinogram)) ')']);

figure(4);
colormap gray;
imagesc(OriginalReconstruction);
title(['Reconstruction with original Sinogram  (' num2str(size(Sinogram)) ')']);

% Calculate Error in the Images
pixels = size(OriginalReconstruction,1) + size(OriginalReconstruction,2);
Error = Reconstruction; % so as the Matrixes have the same size
for i=1:pixels
    Error(i) = ((OriginalReconstruction(i) - Reconstruction(i))^2);
end

E=sum(sum(Error))

Error(:,1) = NaN;
Error(:,2) = NaN;
Error(:,3) = NaN;

figure(5);
colormap gray;
imagesc(Error);
title(['quadratischer Fehler']);


% Give out details of all variables to see what we might have done wrong or
% right...
whos;
