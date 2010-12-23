
%% calculates correlation between imageoverlaps to see how much we have to
%% crop the images on each side.
%% 2008-08-04 adapted from do_correlation_FFT for simulation with Phantom

%% Clear Workspace
clear;
clc;
close all;
tic; % start timer
warning off Images:initSize:adjustingMag % suppress the warning about big images, they are still displayed correctly, just a bit smaller..

%% setup 
path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2';
sample = 'R108C60_22202_';
dir = 'tif';

imgtoread = 512;
rownumber = 512;
adjustbrightness = 0;
showsingleimages = 0;
showrows = 0;
showrowplots = 0;
showcorrelations = 0;
showconcatenatedimages = 0;
showcorrconcatenatedimages = 1;
overlap = 111;

writeas = 'pdf';
writefigures = 0; 
writeimages = 0;

faktor = .5;

%% generally, there is no need to change anything below this line!


%% Setup
Data(1) = struct('Protocol', 'A', 'positions', ['lf';'ct';'rt'], ...
    'dark_im', [], 'flat_im', [], ...
    'left_im', [], 'center_im' , [] , 'right_im' , [], ...
    'left_row', [], 'center_row', [], 'right_row', [], ...
    'left_row_pad', [], 'center_row_pad', [], 'right_row_pad', [], ...
    'LCcorr', [], 'LCcorr_max', [], 'LCcorr_max_idx', [], ...
    'LCmeancorr_max', [], 'LCmeancorr_max_idx', [], ...
    'CRcorr', [], 'CRcorr_max', [], 'CRcorr_max_idx', [], ...
    'CRmeancorr_max', [], 'CRmeancorr_max_idx', [], ...
    'LCswapcorr', [], 'LCswapcorr_max', [], 'LCswapcorr_max_idx', [], ...
    'LCswapmeancorr_max', [], 'LCswapmeancorr_max_idx', [], ...
    'CRswapcorr', [], 'CRswapcorr_max', [], 'CRswapcorr_max_idx', [], ...
    'CRswapmeancorr_max', [], 'CRswapmeancorr_max_idx', [], ...
    'max_brightness', [],  'concat_im', [], 'concat_im_corr', []);
Data(2) = struct('Protocol', 'B', 'positions', ['rg';'ct';'rg'], ...
    'dark_im', [], 'flat_im', [], ...
    'left_im', [], 'center_im' , [] , 'right_im' , [], ...
    'left_row', [], 'center_row', [], 'right_row', [], ...
    'left_row_pad', [], 'center_row_pad', [], 'right_row_pad', [], ...
    'LCcorr', [], 'LCcorr_max', [], 'LCcorr_max_idx', [], ...
    'LCmeancorr_max', [], 'LCmeancorr_max_idx', [], ...
    'CRcorr', [], 'CRcorr_max', [], 'CRcorr_max_idx', [], ...
    'CRmeancorr_max', [], 'CRmeancorr_max_idx', [], ...
    'LCswapcorr', [], 'LCswapcorr_max', [], 'LCswapcorr_max_idx', [], ...
    'LCswapmeancorr_max', [], 'LCswapmeancorr_max_idx', [], ...
    'CRswapcorr', [], 'CRswapcorr_max', [], 'CRswapcorr_max_idx', [], ...
    'CRswapmeancorr_max', [], 'CRswapmeancorr_max_idx', [], ...
    'max_brightness', [], 'concat_im', [], 'concat_im_corr', []);

%% load images
for protocolcounter = 1:1
    groesse=1024;
    phantom = Phantom(groesse)';
    segmentwidth = round( (groesse + 2* overlap )/3) ;
    Data(protocolcounter).left_im   = phantom(:,1:segmentwidth);
    Data(protocolcounter).center_im = phantom(:,segmentwidth - overlap + 1:2 * segmentwidth - overlap );
    Data(protocolcounter).right_im  = phantom(:,2 * ( segmentwidth - overlap ) + 1:size(phantom,2));
    
    % add noise
    Data(protocolcounter).left_im   = imnoise(Data(protocolcounter).left_im,'gaussian',0.0,0.0005);
    Data(protocolcounter).center_im = imnoise(Data(protocolcounter).center_im,'gaussian',0.0,0.0005);
    Data(protocolcounter).right_im  = imnoise(Data(protocolcounter).right_im,'gaussian',0.0,0.0005);

%     leftsize   = size(Data(protocolcounter).left_im)
%     centersize = size(Data(protocolcounter).center_im)
%     rightsize  = size(Data(protocolcounter).right_im)
end

disp('---');
disp('I loaded all images, and show them now if desired');
disp('---');

%% show single images if desired
if showsingleimages == 1
    for protocolcounter = 1:1
        figure
            subplot(121)
                imshow(Data(protocolcounter).dark_im,[])
                title(['dark ' Data(protocolcounter).Protocol])
            subplot(122)
                imshow(Data(protocolcounter).flat_im,[])
                title(['flat ' Data(protocolcounter).Protocol])
        figure
            subplot(131)
                imshow(Data(protocolcounter).left_im,[]);
                title(['left ' Data(protocolcounter).Protocol])
             subplot(132)
                imshow(Data(protocolcounter).center_im,[]);
                title(['center' Data(protocolcounter).Protocol])   
              subplot(133)
                imshow(Data(protocolcounter).right_im,[]);
                title(['right ' Data(protocolcounter).Protocol])  
    end
 end
  
disp('---');
disp('I extracted the rows and show them now if desired');
disp('---');

      
%% show rows if desired
if showrows == 1
    for protocolcounter = 1:1
        figure
            subplot(311)
                imshow(Data(protocolcounter).left_row,[])
                title([Data(protocolcounter).Protocol ' left row'])
            subplot(312)
                imshow(Data(protocolcounter).center_row,[])
                title([Data(protocolcounter).Protocol ' center row'])
             subplot(313)
                imshow(Data(protocolcounter).right_row,[])
                title([Data(protocolcounter).Protocol ' right row'])
    end
end

%% show rowplots if desired
if showrowplots == 1
    for protocolcounter = 1:1
        figure
            subplot(311)
                plot(Data(protocolcounter).left_row)
                title([Data(protocolcounter).Protocol ' left row'])
            subplot(312)
                plot(Data(protocolcounter).center_row)
                title([Data(protocolcounter).Protocol ' center row'])
             subplot(313)
                plot(Data(protocolcounter).right_row)
                title([Data(protocolcounter).Protocol ' right row'])
    end
end
 
disp('---');
disp('I am now computing the cross-correlation');
disp('---');

%% compute FFT

for protocolcounter = 1:1
    ctr = 1;
    faktorcounter = 1;
    for faktor = .05:.1:.95
         Data(protocolcounter).left_row_pad = [];
         Data(protocolcounter).center_row_pad = [];
         Data(protocolcounter).right_row_pad = [];
         FFTL = [];
         FFTC = [];
         FFTR = [];
         Data(protocolcounter).LCcorr = [];
         Data(protocolcounter).CRcorr = [];
         ctr = 1;   
    for rownumber = 150:5:size(Data(protocolcounter).center_im,1)-150
        
        Data(protocolcounter).left_row(ctr,:)   = Data(protocolcounter).left_im(rownumber,:);
        Data(protocolcounter).center_row(ctr,:) = Data(protocolcounter).center_im(rownumber,:);
        Data(protocolcounter).right_row(ctr,:)  = Data(protocolcounter).right_im(rownumber,:);

        % Left - Center
        breiteliste(faktorcounter) = round(size(Data(protocolcounter).center_row,2) * faktor);
        breite = breiteliste(faktorcounter);
        tmpimage = Data(protocolcounter).left_row(ctr, size(Data(protocolcounter).left_row,2) - breite + 1:size(Data(protocolcounter).left_row,2));    
        tmpimage2 = Data(protocolcounter).center_row(ctr,1:size(Data(protocolcounter).center_row,2));
               
%        Data(protocolcounter).left_row_pad(ctr,:)  = [ zeros(1,length(tmpimage2)) tmpimage - mean(Data(protocolcounter).left_row(ctr,:)) ];
%        Data(protocolcounter).center_row_pad(ctr,:) = [ tmpimage2 - mean(Data(protocolcounter).center_row(ctr,:)) zeros(1,length(tmpimage)) ];
        Data(protocolcounter).left_row_pad(ctr,:)  = [ zeros(1,length(tmpimage2)) tmpimage - mean(tmpimage) ];
        Data(protocolcounter).center_row_pad(ctr,:) = [ tmpimage2 - mean(tmpimage2) zeros(1,length(tmpimage)) ];

   
        FFTC(ctr,:) = fft(Data(protocolcounter).center_row_pad(ctr,:)) ./ length(tmpimage2);
        FFTL(ctr,:) = fft(Data(protocolcounter).left_row_pad(ctr,:)) ./ length(tmpimage);
    
        Data(protocolcounter).LCcorr(ctr,:) = ifft(conj(FFTC(ctr,:)) .* FFTL(ctr,:)) ...
            ./ std(tmpimage) ./ std(tmpimage2);
         
        [ Data(protocolcounter).LCcorr_max(ctr,:),Data(protocolcounter).LCcorr_max_idx(ctr,:) ] = ...
            max(Data(protocolcounter).LCcorr(ctr,1:length(Data(protocolcounter).LCcorr)));

        % Center - Right
        tmpimage = Data(protocolcounter).right_row(ctr,1:breite );%size(Data(protocolcounter).right_row,2) );
        tmpimage2 = Data(protocolcounter).center_row(ctr,1:size(Data(protocolcounter).center_row,2));
     
%        Data(protocolcounter).right_row_pad(ctr,:)  = [ zeros(1,length(tmpimage2)) tmpimage - mean(Data(protocolcounter).right_row(ctr,:)) ];
%        Data(protocolcounter).center_row_pad(ctr,:) = [ tmpimage2 - mean(Data(protocolcounter).center_row(ctr,:)) zeros(1,length(tmpimage)) ];
        Data(protocolcounter).right_row_pad(ctr,:)  = [ zeros(1,length(tmpimage2)) tmpimage - mean(tmpimage) ];
        Data(protocolcounter).center_row_pad(ctr,:) = [ tmpimage2 - mean(tmpimage2) zeros(1,length(tmpimage)) ];

        FFTC(ctr,:) = fft(Data(protocolcounter).center_row_pad(ctr,:)) ./ length(tmpimage2);
        FFTR(ctr,:) = fft(Data(protocolcounter).right_row_pad(ctr,:)) ./ length(tmpimage);
    
        Data(protocolcounter).CRcorr(ctr,:) = ifft(conj(FFTC(ctr,:)) .* FFTR(ctr,:)) ...
            ./ std(tmpimage) ./ std(tmpimage2);
         
        [ Data(protocolcounter).CRcorr_max(ctr,:),Data(protocolcounter).CRcorr_max_idx(ctr,:) ] = ...
            max(Data(protocolcounter).CRcorr(ctr,1:length(Data(protocolcounter).CRcorr)));          
        
        % plot the correlations
        if showcorrelations == 1
            figure
                subplot(121)
                    plot(Data(protocolcounter).LCcorr(ctr,:))
                    title(['corr(left,center), protocol ' Data(protocolcounter).Protocol ...
                        ', row ' num2str(rownumber) ...
                        ', min. @ ' num2str(Data(protocolcounter).LCcorr_max_idx(ctr,:)) ' pxs.'])
                subplot(122)
                    plot(Data(protocolcounter).CRcorr(ctr,:))
                    title(['corr(center,right), protocol ' Data(protocolcounter).Protocol ...
                        ', row ' num2str(rownumber) ...
                        ', min. @ ' num2str(Data(protocolcounter).CRcorr_max_idx(ctr,:)) ' pxs.'])
                    
        end
        ctr = ctr + 1;
        
    end
       
    %compute the max and min of the mean correlation
    [ Data(protocolcounter).LCmeancorr_max(faktorcounter),Data(protocolcounter).LCmeancorr_max_idx(faktorcounter)] = ...
            max(mean(Data(protocolcounter).LCcorr));
    [ Data(protocolcounter).CRmeancorr_max(faktorcounter),Data(protocolcounter).CRmeancorr_max_idx(faktorcounter)] = ...
            max(mean(Data(protocolcounter).CRcorr));
        
    %plot the mean correlation
    figure
        subplot(121)
            plot(mean(Data(protocolcounter).LCcorr))
            title({['mean correlation(left,center) for ' num2str(ctr-1) ' rows, protocol ' Data(protocolcounter).Protocol] ...
                   [', max. @ ' num2str(Data(protocolcounter).LCmeancorr_max_idx(faktorcounter)) ' pxs.']})
        subplot(122)
            plot(mean(Data(protocolcounter).CRcorr))
            title({['mean correlation(center,right) for ' num2str(ctr-1) ' rows, protocol ' Data(protocolcounter).Protocol] ...
                   [     ' , max. @ ' num2str(Data(protocolcounter).CRmeancorr_max_idx(faktorcounter)) ' pxs.']})
    
    width(faktorcounter) = faktor;
    faktorcounter = faktorcounter +1;           
    end
    
    figure
        plot(width,Data(protocolcounter).LCmeancorr_max)
        title('LC')
    figure
        plot(width,Data(protocolcounter).CRmeancorr_max)
        title('CR')
        
end

[LCpeak,LCposition] = max(Data(protocolcounter).LCmeancorr_max)
[CRpeak,CRposition] = max(Data(protocolcounter).CRmeancorr_max)

cutpositionLC = Data(protocolcounter).LCmeancorr_max_idx(LCposition) - breiteliste(LCposition)
cutpositionCR = Data(protocolcounter).CRmeancorr_max_idx(CRposition)

disp('---');
disp('I am now showing the concatenated images');
disp('---');

%% concatenate the images
% for protocolcounter = 1:1
%     Data(protocolcounter).concat_im = [ Data(protocolcounter).left_im Data(protocolcounter).center_im Data(protocolcounter).right_im ];
%     if showconcatenatedimages == 1
%         figure
%             imshow(Data(protocolcounter).concat_im,[])
%             title(['concatenated image for protocol ' Data(protocolcounter).Protocol])
%             axis on
%     end
% end

disp('---');
disp('I am now showing the concatenated images with overlap');
disp('---');
 
%% concatenate the images correctly (leave away overlap)
for protocolcounter = 1:1
    Data(protocolcounter).concat_im_corr = [        
        Data(protocolcounter).left_im(:,1:cutpositionLC) ...        % cropped left image
        Data(protocolcounter).center_im ...                                                             % center image 
        Data(protocolcounter).right_im(:,cutpositionCR:size(Data(protocolcounter).right_im,2)) ...
        ];
    if showcorrconcatenatedimages == 1
        figure
            imshow(Data(protocolcounter).concat_im_corr,[])
            title(['corrected concatenated image for protocol ' Data(protocolcounter).Protocol])
            axis on
    end
end

% if writeimages ==1
%     for protocolcounter = 1:1
%         Data(protocolcounter).concat_im_corr = Data(protocolcounter).concat_im_corr - min(min(Data(protocolcounter).concat_im_corr));
%         Data(protocolcounter).concat_im_corr = Data(protocolcounter).concat_im_corr ./ max(max(Data(protocolcounter).concat_im_corr));
%         
%         imwrite(Data(protocolcounter).concat_im_corr,['/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conatenate_overlap/' ...
%             Data(protocolcounter).Protocol '-img' num2str(sprintf('%04d',imgtoread)) ...
%             '.tif'],'Compression','none');
%     end
% end

% close all

toc
disp('---');
disp('I am done!');
disp('---');