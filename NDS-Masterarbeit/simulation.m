%% Clear Workspace
clear;
clc;
close all;
tic; % start timer

%% set parameters
minQ = .3;
maxQ = pi/2;
howmanysteps = 15;
resize = .125;
slabs = 3;               % in how many slabs should the sinogram be splitted?
                         % has to be odd, or else h_SlabInterpolate cannot
                         % calculate anything...
CenterInterpolate = 2;   % what's the desired interpolation in the middle? 
                         % (1=no interpolation, n=every nth line is taken
                         % for interpolating all the others)
RingInterpolate = 1;     % what's the desired interpolation in the ring?
ownphantom = 0;          % use my own phantom =1, use MATLAB phantom = 0
writefigures = 0;        % save figures to disk
writeimages = 0;         % save only the images to disk (no captions!)
writeas = '-depsc';
path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_simulation/preliminary/';

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

disp(['The Phantom is ' num2str(size(Phantom,1)) ' x ' num2str(size(Phantom,2)) ' px big (a'...
      ' diagonal of ' num2str(ceil(sqrt( size(Phantom,1)^2 + size(Phantom,2)^2))) ' px).']);
disp(['The `Detector` is thus assumed to be ' num2str(ceil(size(Phantom,1) / slabs)) ' px wide (so we'...
      ' have ' num2str(slabs) ' slabs).'])

maxpixels = max(size(Phantom));  % get longest side of phantom
quality = minQ:(maxQ-minQ)/(howmanysteps-1):maxQ;

% loop over qualities set throught howmanysteps at the beginning
for stepcounter = 1:length(quality)
%     print time
    toc
    numprojections = maxpixels * quality(stepcounter) % number of projections to actually compute, weighted with quality
    theta=[0:179/(numprojections-1):180]; % number of projections distributed over theta > altered with quality

    %% calculations
    Sinogram = radon(Phantom,theta); % calculate the sinograms
    OriginalSinogram = Sinogram; % store them for output at the end...
        
    % interpolate the middle of the Sinograms
    Sinogram = h_SlabInterpolate(Sinogram,slabs,CenterInterpolate,RingInterpolate); 
   
    % OriginalSinogram = OriginalSinogram ./ max(max(OriginalSinogram));
    
    % calculate the reconstructions, once for the resamples/interpolated
    % Sinogram, and once for the original ones as a reference.
    
    Reconstruction = iradon(Sinogram,theta,'linear','Shepp-Logan',1,maxpixels); % calculate the inverse
    OriginalReconstruction = iradon(OriginalSinogram,theta,'linear','Shepp-Logan',1,maxpixels); % calculate the inverse

%     OriginalSinogram = OriginalSinogram ./ max(max(OriginalSinogram));
%     Phantom = Phantom ./ max(max(Phantom));
%    
%     Reconstruction = Reconstruction ./ max(max(Reconstruction));
%     
%     OriginalReconstruction=OriginalReconstruction ./ max(max(OriginalReconstruction)); 
     
    % Calculate Error in the Images
    BigPhantom = h_PadImage(Phantom,max(size(Phantom)),max(size(Reconstruction)));
%     BigPhantom = BigPhantom ./ max(max(BigPhantom));
    
    ErrorImage = BigPhantom;
    ErrorOriginalImage = BigPhantom;
    ErrorBetweenReconstructions = BigPhantom;
    pixels = size(BigPhantom,1) * size(BigPhantom,2);
    
    ErrorImage = ( single(BigPhantom) - single(Reconstruction) ) ;
    quadError(stepcounter) = sum( sum( ErrorImage .^2 ) );
    
    ErrorOriginalImage = ( single(BigPhantom) - single(OriginalReconstruction) ) ;
    quadOriginalError(stepcounter) = sum( sum( ErrorOriginalImage .^2 ) );
    
    ErrorBetweenReconstructions = ( single(Reconstruction) - single(OriginalReconstruction) ) ;
    quadBetweenReconstructionsError(stepcounter) = sum( sum( ErrorBetweenReconstructions .^2 ) );
    
    for linecounter=1:slabs-1
        Sinogram(linecounter*floor(size(Sinogram,1)/slabs),:) = max(max(Sinogram));
    end
    
    %% Display
    figure(5*stepcounter-4);
        subplot(1,2,1)
        colormap gray;
        imagesc(Sinogram');
        axis image;
        title({['Step ' num2str(stepcounter) ': Interpolated Sinograms, Quality= ' num2str(quality(stepcounter))];...
               ['with (approx.!) overlayed slabs (' num2str(slabs) ')'];...
               ['center slab interpolated from every ' num2str(CenterInterpolate) '. line,'];...
               ['first ring interpolated from every ' num2str(RingInterpolate) '. line.']});        
        subplot(1,2,2)
        colormap gray;
        imagesc(OriginalSinogram');
        axis image;
        title(['Step ' num2str(stepcounter) ': Original Sinograms, Quality= ' num2str(quality(stepcounter))]);
        if writefigures == 1
            print(writeas, [path num2str(sprintf('%03d',stepcounter)) '-fig-sinograms']);
            close;
        else
        end
    
    figure(5*stepcounter-3);
        colormap gray;
        imagesc(Phantom);
        axis image;
        title(['Step ' num2str(stepcounter) ': Phantom']);
        if writefigures == 1
            print(writeas, [path num2str(sprintf('%03d',stepcounter)) '-fig-original']);
            close;
        else
        end

    figure(5*stepcounter-2);
        colormap gray;
       imagesc(Reconstruction);
        axis image;  
        title({['Step ' num2str(stepcounter) ': Reconstruction with interpolated Sinogram (' num2str(size(Sinogram)) ')'];...
               ['center interpolated from every ' num2str(CenterInterpolate) '. line,'];...
               ['first ring interpolated from every ' num2str(RingInterpolate) '. line.']});        
        if writefigures == 1
            print(writeas, [path num2str(sprintf('%03d',stepcounter)) '-fig-reco-int']);
            close;
        else
        end
    
    figure(5*stepcounter-1);
        colormap gray;
        imagesc(OriginalReconstruction);
        axis image;
        title(['Step ' num2str(stepcounter) ': Reconstruction with original Sinogram (' num2str(size(Sinogram)) ')']);
        if writefigures == 1
            print(writeas, [path num2str(sprintf('%03d',stepcounter)) '-fig-reco-orig']);
            close;
        else
        end

   
    figure(5*stepcounter);
        colormap gray;
        imagesc(ErrorImage);
        axis image;
        title(['Step ' num2str(stepcounter) ': Phantom - Reconstruction. quadratic Error = ' num2str(quadError(stepcounter))]);
        disp(['In Step ' num2str(stepcounter) ' the quality is ' num2str(quality(stepcounter)) ...
              ' and the error is ' num2str(round(quadError(stepcounter)))])
        if writefigures == 1
            print(writeas, [path num2str(sprintf('%03d',stepcounter)) '-fig-error']);
            close;
        else
        end
    
    if writeimages ==1
        imwrite(Sinogram',[path num2str(sprintf('%03d',stepcounter)) '-img-sinogram.png']);
        imwrite(OriginalSinogram',[path num2str(sprintf('%03d',stepcounter)) '-img-orig-sinogram.png']);
        imwrite(Phantom,[path num2str(sprintf('%03d',stepcounter)) '-img-phantom.png']);
        imwrite(Reconstruction,[path num2str(sprintf('%03d',stepcounter)) '-img-reco.png']);
        imwrite(OriginalReconstruction,[path num2str(sprintf('%03d',stepcounter)) '-img-orig-reco.png']);
        imwrite(ErrorImage,[path num2str(sprintf('%03d',stepcounter)) '-img-quaderror.png']);
    else
    end

    stepcounter = stepcounter + 1;
    
%     MinPhantom = min(min(Phantom))
%     MaxPhantom = max(max(Phantom))
%     MinSino = min(min(Sinogram))
%     MaxSino = max(max(Sinogram))
%     MinReconstruction = min(min(Reconstruction))
%     MaxReconstruction = max(max(Reconstruction))

end

figure(5*stepcounter+1);
    semilogy(quality,quadError,'r-+',quality,quadOriginalError,'b--o');
    % define nice graph borders
    minimum = min([quadError quadOriginalError ]);
    maximum = max([quadError quadOriginalError ]);
    % set nice graph borders, title, legend and axis
    axis([minQ-0.1*minQ  maxQ+0.1*maxQ  minimum-0.1*minimum maximum+0.1*maximum]);
    title(['normed quad. Error for ' num2str(howmanysteps) ' Steps, for an phantom size of (' num2str(size(Phantom)) ') pixels']);
    legend('E^2=\Sigma(O - R_i)^2','E^2=\Sigma(O - R_o)^2');
    set(gca,'Xgrid','on','Ygrid','on');
    if writeimages == 1 || writefigures == 1 
        print(writeas,[path 'error-tuple-for-' num2str(howmanysteps) '-steps']);
        close;
    else
    end 

figure(5*stepcounter+2);
    semilogy(quality,quadError,'r-+',quality,quadOriginalError,'b--o',quality,quadBetweenReconstructionsError,'g-.*');
    % define nice graph borders
    minimum = min([quadError quadOriginalError quadBetweenReconstructionsError]);
    maximum = max([quadError quadOriginalError quadBetweenReconstructionsError]);
    % set nice graph borders, title, legend and axis
    axis([minQ-0.1*minQ  maxQ+0.1*maxQ  minimum-0.1*minimum maximum+0.1*maximum]);
    title(['normed quad. Error for ' num2str(howmanysteps) ' Steps, for an phantom size of (' num2str(size(Phantom)) ') pixels']);
    legend('E^2=\Sigma(O - R_i)^2','E^2=\Sigma(O - R_o)^2','E^2=\Sigma(R_o - R_i)^2');
    set(gca,'Xgrid','on','Ygrid','on');
    if writeimages == 1 || writefigures == 1 
        print(writeas,[path 'error-triple-for-' num2str(howmanysteps) '-steps']);
        close;
    else
    end
    
figure(5*stepcounter+3);
    semilogy(quality,quadError,'r-+',quality,quadOriginalError,'b--o');
    % define nice graph borders
    minimum = min([quadError quadOriginalError ]);
    maximum = max([quadError quadOriginalError ]);
    % set nice graph borders, title, legend and axis
    set(gcf,'nextplot','add');
    ax1 = gca;
    set(gca,'Xgrid','on','Ygrid','on');
    set(ax1,'XColor','k','YColor','k','xlim',[minQ-0.1*minQ maxQ+0.1*maxQ],'ylim',[minimum-0.1*minimum maximum+0.1*maximum])
    l1 = legend(ax1,'E^2=\Sigma(O - R_i)^2','E^2=\Sigma(O - R_o)^2');%,'E^2=\Sigma(R_o - R_i)^2');
    minimum = min(quadBetweenReconstructionsError);
    maximum = max(quadBetweenReconstructionsError);
    ax2 = axes('Position',get(ax1,'Position'),...
           'YAxisLocation','right',...
           'Color','none',...
           'nextplot','add',...
           'xlim',[minQ-0.1*minQ maxQ+0.1*maxQ],'ylim',[minimum-0.1*minimum maximum+0.1*maximum]);
    set(get(ax2,'YLabel'),'String','E_{\Delta}^2')
    set(get(ax1,'YLabel'),'String','E^2')
    semilogy(quality,quadBetweenReconstructionsError,'g-.*')
    title(['normed quad. Error for ' num2str(howmanysteps) ' Steps, for an phantom size of (' num2str(size(Phantom)) ') pixels']);
    l2=legend(ax2,'E_{\Delta}^2=\Sigma(R_o - R_i)^2');
    p=get(l1,'position');
    set(l2,'position',p - [ 0 p(4) 0 0],'color',get(l1,'color'))
    %set(l1,'position',p + [ 0 -p(4) 0 p(4)]);
    set(gca,'Xgrid','on','Ygrid','on');
    set(gca,'nextplot','replace');
    set(gcf,'nextplot','replace');
    %if writeimages == 1 || writefigures == 1 
        print(writeas,[path 'error-triple-for-' num2str(howmanysteps) '-steps-2axes']);
       % close;
    %else
    %end
    
% Give out details of all variables to see what we might have done wrong or
% right...
% whos;

% output timing
toc