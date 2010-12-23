% Simulates the Protocols, that Xris and me have defined for doing a
% wide-field scan. Selfcontained MATLAB-File except when the user chooses
% to use a self-drawn phantom, which is just a png-file with different
% blocks and grayvalues

% 2008.03.06: Added Output-Option to save images and updated to use correct
%             theta
% 2008.06.02: First Version

%% Start with a clean state.
clear;
close all;
clc;
tic;

%% Set parameters
imagesize = 1024;
showfigures = 1;  % show the Sinograms and Reconstructions?
writefigures = 0; % shall I write the Images to 'path' / writedir? (only works if showfigures = 1!)
writeas = '-depsc';
usemyphantom = 0;
closeatend = 0;   % close all images when finished?

%% set paths and so
samplename = 'simulation';
path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/';
writedir = '_simulation';
imagesizestr = sprintf('%04d',imagesize);

% generally, there is no need to change anything below this line!

%% Setup the Protocol-Parameters in a Structurepack
%skip = factor used to calculate the coefficient of out to in
Protocols(1) = struct('Name', 'A', 'out'  , 6001 , 'in' , 3001, 'skip' , 1   , 'sin', [], 'rec' , [] , 'Diff' , [], 'quaderror', 0 ,'errora' , 0 ) ;
Protocols(2) = struct('Name', 'B', 'out'  , 6001 , 'in' , 3001, 'skip' , 1   , 'sin', [], 'rec' , [] , 'Diff' , [], 'quaderror', 0 ,'errora' , 0 ) ;
Protocols(3) = struct('Name', 'C', 'out'  , 6001 , 'in' , 1501, 'skip' , 1   , 'sin', [], 'rec' , [] , 'Diff' , [], 'quaderror', 0 ,'errora' , 0 ) ;
Protocols(4) = struct('Name', 'C1','out'  , 6001 , 'in' , 1001, 'skip' , 1   , 'sin', [], 'rec' , [] , 'Diff' , [], 'quaderror', 0 ,'errora' , 0 ) ;
Protocols(5) = struct('Name', 'D', 'out'  , 4001 , 'in' , 1001, 'skip' , 1.5 , 'sin', [], 'rec' , [] , 'Diff' , [], 'quaderror', 0 ,'errora' , 0 ) ;
Protocols(6) = struct('Name', 'E', 'out'  , 3001 , 'in' , 1501, 'skip' , 2   , 'sin', [], 'rec' , [] , 'Diff' , [], 'quaderror', 0 ,'errora' , 0 ) ;
Protocols(7) = struct('Name', 'F', 'out'  , 2001 , 'in' , 1001, 'skip' , 3   , 'sin', [], 'rec' , [] , 'Diff' , [], 'quaderror', 0 ,'errora' , 0 ) ;

%% Make Directory for saving the images
if writefigures == 1
    [status,message,messageid] = mkdir( [ path writedir '/' imagesizestr ] );
end

%% generate Phantom
if usemyphantom == 0
    Phantom = phantom(imagesize);
elseif usemyphantom == 1
    Phantom = double(imread('/afs/psi.ch/user/h/haberthuer/images/phantom512.png','png'));
    Phantom = double(imread('/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/R108C60_22_20x_B_conc/rec/R108C60_22_20x_B_conc0256.rec.tif','tif'));
    Phantom = imresize(Phantom,imagesize/max(size(Phantom)));
end

wait = waitbar(0,'please wait, i`m calculating...');

%% Calculate
for protocol = 1: length(Protocols)
    waitbar(protocol/length(Protocols));
    % setup Theta for Protocols
    interm = ( 180 / ( ( Protocols(protocol).out - 1 ) / 2 ) );
%    interm = 1;
    theta = 0:interm*Protocols(protocol).skip:179;
         
    %% generate Sinogram
    Protocols(protocol).sin = [radon(Phantom,theta)]';
    disp(['done with sinogram generation ' Protocols(protocol).Name ' , starting interpolation'])
    
    %% interpolate the center of the sinogram accordingly
    SinogramLeft   = Protocols(protocol).sin(:,1:floor(size(Protocols(protocol).sin,2)/3));
    SinogramCenter = Protocols(protocol).sin(:,floor(size(Protocols(protocol).sin,2)/3)+1:floor(2*size(Protocols(protocol).sin,2)/3));
    SinogramRight  = Protocols(protocol).sin(:,floor(2*size(Protocols(protocol).sin,2)/3)+1:size(Protocols(protocol).sin,2));
%     figure
%         subplot(131)
%         imagesc(SinogramLeft);
%         axis image
%         colormap gray
%         subplot(132)
%         imagesc(SinogramCenter)
%         axis image
%         colormap gray
%         subplot(133)
%         imagesc(SinogramRight);
%         axis image
%         colormap gray
    int = ( (Protocols(protocol).out-1) / (Protocols(protocol).in-1) ) * 0.5;
    for i = 1:size(SinogramCenter,2)
      
%         t = 1900:10:1990;
%         p = [75.995  91.972  105.711  123.203  131.669...
%          150.697  179.323  203.212  226.505  249.633];
% 
%         x = 1800:1:2022;
%         y = interp1(t,p,x,'linear','extrap');

        SinogramCenter(:,i) = interp1(1:int:size(SinogramCenter,1),SinogramCenter(1:int:size(SinogramCenter,1),i),1:size(SinogramCenter,1),'linear','extrap'); 
        
    end

%     figure
%         subplot(131)
%         imagesc(SinogramLeft);
%         axis image
%         colormap gray
%         subplot(132)
%         imagesc(SinogramCenter)
%         axis image
%         colormap gray
%         subplot(133)
%         imagesc(SinogramRight);
%         axis image
%         colormap gray

    Protocols(protocol).sin(:,floor(size(Protocols(protocol).sin,2)/3)+1:floor(2*size(Protocols(protocol).sin,2)/3)) = SinogramCenter;
    if showfigures == 1
        figure()
            imagesc(Protocols(protocol).sin)
            axis image
            colormap gray;
            title('sinogram')
            colorbar
            title(['interpolated Sinogram ' Protocols(protocol).Name ])
            if writefigures == 1
            filename = [ path writedir '/' imagesizestr '/' imagesizestr '-sinogram-' Protocols(protocol).Name ];
            print(writeas, filename);
        end
    end

    %% Reconstruction
    disp(['done with interpolation ' Protocols(protocol).Name ', starting reconstruction'])
    Protocols(protocol).rec = iradon(Protocols(protocol).sin',theta,'linear','Shepp-Logan',1,imagesize);
    if showfigures == 1 
        figure()
            imagesc(Protocols(protocol).rec)
            axis image
            colormap gray;
            title(['Reconstruction ' Protocols(protocol).Name ])
            colorbar
        if writefigures == 1
            filename = [ path writedir '/' imagesizestr '/' imagesizestr '-reconstruction-' Protocols(protocol).Name ];
            print(writeas, filename);
        end
    end

    %% Error Calculation
    disp(['done with reconstruction ' Protocols(protocol).Name ' , starting calculation'])
    
    Protocols(protocol).Diff = ( Phantom - Protocols(protocol).rec );
    Protocols(protocol).quaderror = sum( sum( Protocols(protocol).Diff .^2 ) );
    Protocols(protocol).errora = sum( sum( ( Protocols(1).rec - Protocols(protocol).rec ) .^2 ) );
    
    if showfigures == 1 
        figure()
            imagesc(Protocols(protocol).Diff)
            axis image
            colormap gray;
            title(['Difference Image of Phantom with Reconstruction ' Protocols(protocol).Name ])
            colorbar
        if writefigures == 1
            filename = [ path writedir '/' imagesizestr '/' imagesizestr '-differenceimage-' Protocols(protocol).Name ];
            print(writeas, filename);
        end
    end
end

close(wait)

%% Display Error Plot
figure();
    %% plot1    
        plot(1:length(Protocols),[Protocols(:).quaderror],'-xr');
        xlabel('Protocol')
        ylabel('Error to Phantom')
        set(gca,'XTick',[1:length(Protocols)])
        set(gca,'XTickLabel',{Protocols(:).Name})
        w=legend('Error to Phantom','Location','NorthWest');
    %% plot2
        axes('Color','none','Position',get(gca,'Position'),'YAxisLocation','right')
        hold on
        plot(1:length(Protocols),[Protocols(:).errora],'-ob')
        set(gca,'YGrid','on')
        xlabel('Protocol')
        ylabel('Error to Protocol A (Gold Standard)')
        set(gca,'XTick',[1:length(Protocols)])
        set(gca,'XTickLabel',{Protocols(:).Name})
        u=legend('Error to Reconstruction A','Location','NorthWest');
        % trick used for correct placement of second legend
        m = get(w,'position');
        f = get(u,'position');
        f(2) = f(2) - m(4);
        set(u,'position',f,'color','none')
        m(1) = f(1);
        m(3) = f(3);
        set(w,'position',m,'color','none')
        title(['quadratic Error for SIMULATED Protocols compared to `A`, (imagesize = ' num2str(imagesize) ' px)']);
        hold off
if writefigures == 1
    filename = [ path writedir '/' imagesizestr '/' imagesizestr '-errorplot' ];
    print(writeas, filename);
end   

%% Finish
if closeatend == 1
    close all
end
disp('Finished with everything you asked for.');
toc;