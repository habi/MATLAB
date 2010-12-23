%% Clear Workspace
clear;
clc;
%close all;

%% Setup for User-Variables
minQ = 0.25;             % where should we start?
maxQ = pi/2;             % how far do we want to go?
howmanysteps = 60;       % in how many steps?
resize = .5;            % resize-factor for Phantom (1=leave alone/don't resize)
showreconstructions = 0; % show an image with the reconstructions for every step or not?
ownphantom = 0;          % use my own phantom =1, use MATLAB phantom = 0
writefigures = 0;        % save figures to disk
%writeimages = 0;         % save only the images to disk (no captions...)


% generally, there is no need to edit stuff below this line
% ---------------------------------------------------------

%% setup (base image and quality factor)
if ownphantom == 1
    Phantom = double(imread('/afs/psi.ch/user/h/haberthuer/images/phantom512.png','png'));
else
    Phantom = phantom(512); % use MATLAB-Phantom
end
% resize input image to a smaller size > faster calculations for testing...
Phantom = imresize(Phantom,resize);

%% set parameters
maxpixels = max(size(Phantom)); % size of Phantom, needed for assignment of quality
% Sampling Theorem: Pixel count of the length * Pi/2 is the ideal amount of 
% projections, so we scale the number of projections with the quality assigned by the
% user at the beginning and make minimal and maximal amout to calculate.
% Afterwards, we put 'howmanysteps' steps inbetween, so we have the chosen
% amount of steps
minnumprojections = floor(maxpixels * minQ); 
maxnumprojections = ceil(maxpixels * maxQ);
numprojections = minnumprojections:round((maxnumprojections-minnumprojections)/(howmanysteps-1)):maxnumprojections;
quality = numprojections./maxpixels;
% set other parameters needed for calculation
stepcount = 1; % defines subplot-position and matrix-element.
Error = zeros(1,howmanysteps); % Empty Array to save the Error into

%% iterate quality and plot it 
% firs plot original reconstruction into big enough subplot
BigPhantom = h_PadImage(Phantom,max(size(Phantom)),max(size(Phantom))+2); 
%workaround for OutputSize, since we don't yet know size(Reconstruction)...
if showreconstructions == 1
    figure(1);
    colormap gray;
    subplot(ceil(sqrt(howmanysteps))+1,ceil(sqrt(howmanysteps)),stepcount);
    imshow(BigPhantom,[]);
    title(['original']);
else
end

% loop over quality from lowest to highest. stepsize is 'encoded' in the
% elements of numprojectios, which we have calculated above.
for stepcount = 1:length(numprojections)
    % tell the user how far we are...
    % disp(['calculating step ' num2str(stepcount) ' of ' num2str(howmanysteps)])
    clc;
    disp(['working on ' num2str(round(stepcount / howmanysteps * 100)) '% of the work to do...'])
    % number of projections to actually compute, weighted with quality
    theta=[0:179/(numprojections(stepcount)-1):180];
    % calculate the sinograms  
    Sinogram = radon(Phantom,theta);
    % do the reconstruction
    Reconstruction = iradon(Sinogram,theta);
    % calculate the quad. Error of the single Reconstructions 
    quadError(stepcount) = sum( sum( (BigPhantom - Reconstruction).^2 ) );
    if showreconstructions ==1
        % Plot the reconstruction for the current quality-step
        subplot(ceil(sqrt(howmanysteps+1)),ceil(sqrt(howmanysteps)),stepcount);
        imshow(Reconstruction,[]);
        title(['q=' num2str(quality(stepcount))]);
    else
    end
end
 

        
%% plot Error
% make new figure, plot the Error
% figure(2);
% % x = ;
% % y = quadError;
% plot([baseQ:step:maxQ],quadError,'--rs','MarkerEdgeColor','k','MarkerSize',5);
% title('Error');
% %axis([0 maxQ 0 max(Error)]);
% make new figure, plot the Error with log_y-axes.
%figure(3);

%calculate position of minima
[tmp, Minima] = min(quadError);
minimalQuality = quality(Minima);

figure;
semilogy(quality,quadError,'--rs','MarkerEdgeColor','k','MarkerSize',5);
title({['Log of quadr. Error between Phantom & Reconstruction for ' num2str(howmanysteps) ' different sampling qualities'];...
       ['ranging from ' num2str(minQ) ' to ' num2str(maxQ) ' and for a phantom size of (' num2str(size(Phantom)) ') pixels'];...
       ['absolute Minima @ ' num2str(minimalQuality)]});
axis([0  maxQ+0.1*maxQ  min(quadError)-0.1*min(quadError) max(quadError)+0.1*max(quadError)]);
xlabel({'Quality of the Projections';'equals # of Projections used for Reconstruction divided by Pixelsize of Image'});
set(gca,'Xgrid','on','Ygrid','on');

resize = 1000 * resize; %damit filenamen in LaTeX funktionieren...

if writefigures == 1
    print('-dpng',[num2str(howmanysteps) '-steps-0' num2str(resize) '-resize-error-plot']);
    close;
    if showreconstructions == 1
        print('-dpng',[num2str(howmanysteps) '-steps-0' num2str(resize) '-resize-reconstructions']);
        close;
    else
    end
else
end

% end

% Give out details of all variables to see what we might have done wrong or right...
whos;