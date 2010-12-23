
%% Clear Workspace
clear;
clc;
close all;
tic; % start timer

%% set parameters
usemyphantom = 0;      % use my own phantom =1, use MATLAB-phantom = 0
resizefactor = .25;     % how much should we resize the phantom to speed up the calculations?        
DetectorWidth = 23;    % what's the width of our detector? > defines # of Slabs/Rings
slabs = 3; 
% generally, there is no need to edit stuff below this line
% ---------------------------------------------------------

%% Initialization
% which phantom should we use?
if usemyphantom == 1
    Phantom = double(imread('/afs/psi.ch/user/h/haberthuer/images/phantom512.png','png'));
else
    Phantom = phantom(512);
end

% resize phantom if desired (don't do anything when resize == 1 to save
% time...
if resizefactor == 1
else
   Phantom = imresize(Phantom,resizefactor);
end


%% Get necessary parameters from the Inputs and calculate some others
InputImageMaxWidth = ceil( sqrt( size( Phantom,1 ) ^2 + size( Phantom,2 ) ^2 ) ); % ...a^2+b^2=c^2
RingsSlabs = h_HowManyRings(InputImageMaxWidth,DetectorWidth);
HowManyRings = RingsSlabs(1);
ScreenSize = get(0,'ScreenSize'); % needed to nicely arrange the figures on the screen...

%% Calculations
Sinogram = radon(Phantom);

% figure;
% image(Sinogram);
% axis image;

Sinogram = h_SlabInterpolate(Sinogram,slabs);

Reconstruction = iradon(Sinogram,[]);
%Reconstruction = Reconstruction(1:size(Phantom,1),1:size(Phantom,2));
PaddedReconstruction = h_PadImage(Reconstruction,max(size(Reconstruction)),max(size(Phantom)));
Diff = Phantom - PaddedReconstruction;

%% Output
figure('Name','Phantom','color','w','Position',[20 100 ScreenSize(3)/3 ScreenSize(4)/3])
colormap gray
imagesc(Phantom)
% axis off          % remove ticks and numbers
axis image        % set aspect ratio to obtain square pixels
title(['Phantom-Size: ' num2str(size(Phantom,1)) 'x' num2str(size(Phantom,2)) ' Px'])

figure('Name','Sinogram (transposed)','color','w','Position',[320 100 ScreenSize(3)/3 ScreenSize(4)/3])
colormap gray
imagesc(Sinogram)
%axis off
axis image
% title({'First line';'Second line'})
title({['Sinogram-Size: ' num2str(size(Sinogram,1)) 'x' num2str(size(Sinogram,2)) ' px' ];...
       ['Phantom-Size: ' num2str(size(Phantom,1)) 'x' num2str(size(Phantom,2)) ' px. Diagonal; ' num2str(InputImageMaxWidth) ' px']})

figure('Name','Reconstruction','color','w','Position',[620 100 ScreenSize(3)/3 ScreenSize(4)/3])
colormap gray
imagesc(Reconstruction)
%axis off
axis image
title(['Reconstruction-Size: ' num2str(size(Reconstruction,1)) 'x' num2str(size(Reconstruction,2)) ' Px'])

figure('Name','Difference Image','color','w','Position',[920 100 ScreenSize(3)/3 ScreenSize(4)/3])
colormap gray
imagesc(Diff)
%axis off
axis image
title(['Diff-Size: ' num2str(size(Diff,1)) 'x' num2str(size(Diff,2)) ' Px'])

% whos % output all used parameters
toc % output timer started with `tic`