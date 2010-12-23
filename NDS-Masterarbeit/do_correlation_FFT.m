
%% calculates correlation between imageoverlaps to see how much we have to
%% crop the images on each side.
%% 2008-07-18 initial version
%% 2008-07-21 started to work on own correlation-mode, since xcorr doesn't
%% work as intende
%% 2008-07-25 tried to implement my own correlation
%% 2008-07-28 finally the correlation seems to work, switched back to
%% crosscorelation
%% 2008-07-29 print the correlations to files

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
adjustbrightness = 0;
showsingleimages = 0;
showrows = 0;
showrowplots = 0;
showcorrelations = 1;
showconcatenatedimages = 1;
showcorrconcatenatedimages = 1;

writeas = 'pdf';
writefigures = 0; 
writeimages = 0;

%% generally, there is no need to change anything below this line!


%% Setup
Data(1) = struct('Protocol', 'A', 'positions', ['lf';'ct';'rt'], ...
    'dark_im', [], 'flat_im', [], ...
    'left_im', [], 'center_im' , [] , 'right_im' , [], ...
    'left_row', [], 'center_row', [], 'right_row', [], ...
    'left_row_pad', [], 'center_row_pad', [], 'right_row_pad', [], ...
    'LCcorr', [], 'LCcorr_max', [], 'LCcorr_max_idx', [], ...
    'CRcorr', [], 'CRcorr_max', [], 'CRcorr_max_idx', [], ...
    'max_brightness', [],  'concat_im', [], 'concat_im_corr', []);
Data(2) = struct('Protocol', 'B', 'positions', ['rg';'ct';'rg'], ...
    'dark_im', [], 'flat_im', [], ...
    'left_im', [], 'center_im' , [] , 'right_im' , [], ...
    'left_row', [], 'center_row', [], 'right_row', [], ...
    'left_row_pad', [], 'center_row_pad', [], 'right_row_pad', [], ...
    'LCcorr', [], 'LCcorr_max', [], 'LCcorr_max_idx', [], ...
    'CRcorr', [], 'CRcorr_max', [], 'CRcorr_max_idx', [], ...
    'max_brightness', [], 'concat_im', [], 'concat_im_corr', []);

%% load images
for protocolcounter = 1:2
    for positioncounter = 1:3
        name = [ sample Data(protocolcounter).Protocol ...
            '_' Data(protocolcounter).positions(positioncounter,:) ];
        imagenumber = imgtoread;
        % if at 180+ of B, then increase the imagecounter to 180+...
        if protocolcounter == 2 && positioncounter == 1
            imagenumber = imgtoread + 3000;
        end
        %
        disp(['I am currently loading image number ' num2str(imagenumber) ' of protocol ' Data(protocolcounter).Protocol '-' Data(protocolcounter).positions(positioncounter,:) ]);
        loaddarkimage = [ path '/' name '/' dir '/' name '0002.tif' ];
        Data(protocolcounter).dark_im = double(imread(loaddarkimage)) .* 0.5;
        
        loadflatimage  = [ path '/' name '/' dir '/' name '0004.tif' ];
        Data(protocolcounter).flat_im = double(imread(loadflatimage)) .* 0.5;
        Data(protocolcounter).flat_im = log(Data(protocolcounter).flat_im - Data(protocolcounter).dark_im);
        
        loadimage = [ path '/' name '/' dir '/' name sprintf('%04d',imagenumber) '.tif' ];
        image = double(imread(loadimage)) .* 0.5;
        image = Data(protocolcounter).flat_im - log(image - Data(protocolcounter).dark_im);
                              
        if positioncounter == 1
            Data(protocolcounter).left_im = image;
        elseif positioncounter == 2
            Data(protocolcounter).center_im = image;
        elseif positioncounter == 3
            Data(protocolcounter).right_im = image;
        end
        
        % flip left image of Protocol B, so we can concatenate lateron...
        if protocolcounter == 2 && positioncounter == 1
            Data(protocolcounter).left_im = fliplr(Data(protocolcounter).left_im);
            disp('I just flipped the 180� image of protocol B, so everything worked up to now');
        end
        %
    end

end

disp('---');
disp('I loaded all images, and show them now if desired');
disp('---');

%% show single images if desired
if showsingleimages == 1
    for protocolcounter = 1:2
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
    for protocolcounter = 1:2
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
    for protocolcounter = 1:2
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

for protocolcounter = 1:2
    
    ctr = 1;
    for rownumber = 1:round(1024/10):1024
        
        Data(protocolcounter).left_row(ctr,:)   = Data(protocolcounter).left_im(rownumber,:);
        Data(protocolcounter).center_row(ctr,:) = Data(protocolcounter).center_im(rownumber,:);
        Data(protocolcounter).right_row(ctr,:)  = Data(protocolcounter).right_im(rownumber,:);
        
        % Left - Center
        Data(protocolcounter).left_row_pad(ctr,:)  = [ Data(protocolcounter).left_row(ctr,:) - mean(Data(protocolcounter).left_row(ctr,:)) ...
                                                       zeros(1,length(Data(protocolcounter).center_row(ctr,:))) ];
        Data(protocolcounter).center_row_pad(ctr,:) = [ zeros(1,length(Data(protocolcounter).left_row(ctr,:))) ... 
                                                       Data(protocolcounter).center_row(ctr,:) - mean(Data(protocolcounter).center_row(ctr,:)) ];
   
        FFTC(ctr,:) = fft(Data(protocolcounter).center_row_pad(ctr,:)) ./ length(Data(protocolcounter).center_row_pad(ctr,:));
        FFTL(ctr,:) = fft(Data(protocolcounter).left_row_pad(ctr,:)) ./ length(Data(protocolcounter).left_row_pad(ctr,:));
    
        Data(protocolcounter).LCcorr(ctr,:) = ifft(conj(FFTC(ctr,:)) .* FFTL(ctr,:)) ...
            ./ std(Data(protocolcounter).left_row(ctr,:)) ...
            ./ std(Data(protocolcounter).center_row(ctr,:));
         
        [ Data(protocolcounter).LCcorr_max(ctr,:),Data(protocolcounter).LCcorr_max_idx(ctr,:) ] = max( Data(protocolcounter).LCcorr(ctr,1:1024));
        
        % Center - Right
        Data(protocolcounter).center_row_pad(ctr,:) = [ zeros(1,length(Data(protocolcounter).right_row(ctr,:))) ...
            Data(protocolcounter).center_row(ctr,:) - mean(Data(protocolcounter).center_row(ctr,:))];
        Data(protocolcounter).right_row_pad(ctr,:)  = [ Data(protocolcounter).right_row(ctr,:) ...
            - mean(Data(protocolcounter).right_row(ctr,:)) zeros(1,length(Data(protocolcounter).center_row(ctr,:)))];
  
        FFTR(ctr,:) = fft(Data(protocolcounter).right_row_pad(ctr,:)) ./ length(Data(protocolcounter).right_row_pad(ctr,:));
        FFTC(ctr,:) = fft(Data(protocolcounter).center_row_pad(ctr,:)) ./ length(Data(protocolcounter).center_row_pad(ctr,:));
    
        Data(protocolcounter).CRcorr(ctr,:) = ifft(conj(FFTR(ctr,:)) .* FFTC(ctr,:)) ...
            ./ std(Data(protocolcounter).center_row(ctr,:)) ...
            ./ std(Data(protocolcounter).right_row(ctr,:));
          
        [ Data(protocolcounter).CRcorr_max(ctr,:),Data(protocolcounter).CRcorr_max_idx(ctr,:) ] = min( Data(protocolcounter).CRcorr(ctr,1:1024));

        % plot the correlations
        if showcorrelations == 1
            figure('Position',[40*protocolcounter 128*protocolcounter 1024 512])
                subplot(121)
                    plot(Data(protocolcounter).LCcorr(ctr,:))
                    title(['corr(left,center), protocol ' Data(protocolcounter).Protocol ...
                        ', row ' num2str(rownumber) ...
                        ', maximum @ ' num2str(Data(protocolcounter).LCcorr_max_idx(ctr,:)) ' pxs.'])
                subplot(122)
                    plot(Data(protocolcounter).CRcorr(ctr,:))
                    title(['corr(center,right), protocol ' Data(protocolcounter).Protocol ...
                        ', row ' num2str(rownumber) ...
                        ', maximum @ ' num2str(Data(protocolcounter).CRcorr_max_idx(ctr,:)) ' pxs.'])
        end

        ctr = ctr + 1;
    end
    Data(protocolcounter).LCcorr_max_idx = mean(Data(protocolcounter).LCcorr_max_idx);
    Data(protocolcounter).CRcorr_max_idx = mean(Data(protocolcounter).CRcorr_max_idx);
    
end

disp('---');
disp('I am now showing the concatenated images');
disp('---');

%% concatenate the images
for protocolcounter = 1:2
    Data(protocolcounter).concat_im = [ Data(protocolcounter).left_im Data(protocolcounter).center_im Data(protocolcounter).right_im ];
    if showconcatenatedimages == 1
        figure
            imshow(Data(protocolcounter).concat_im,[])
            title(['concatenated image for protocol ' Data(protocolcounter).Protocol])
    end
end

disp('---');
disp('I am now showing the concatenated images with overlap');
disp('---');
 
%% concatenate the images correctly (leave away overlap)
for protocolcounter = 1:2
    Data(protocolcounter).concat_im_corr = [ ...
        zeros(length(Data(protocolcounter).left_im),round(Data(protocolcounter).LCcorr_max_idx/2)) ...
        Data(protocolcounter).left_im(:,1:1024-round(Data(protocolcounter).LCcorr_max_idx/2)) ...
        Data(protocolcounter).center_im ...
        Data(protocolcounter).right_im(:,round(Data(protocolcounter).CRcorr_max_idx/2):1024) ...
        zeros(length(Data(protocolcounter).right_im),round(Data(protocolcounter).CRcorr_max_idx/2)) ];
    if showcorrconcatenatedimages == 1
        figure
            imshow(Data(protocolcounter).concat_im_corr,[])
            title(['corrected concatenated image for protocol ' Data(protocolcounter).Protocol])
    end
end

if writeimages ==1
    for protocolcounter = 1:2
        Data(protocolcounter).concat_im_corr = Data(protocolcounter).concat_im_corr - min(min(Data(protocolcounter).concat_im_corr));
        Data(protocolcounter).concat_im_corr = Data(protocolcounter).concat_im_corr ./ max(max(Data(protocolcounter).concat_im_corr));
        
        imwrite(Data(protocolcounter).concat_im_corr,['/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conatenate_overlap/' ...
            Data(protocolcounter).Protocol '-img' num2str(sprintf('%04d',imgtoread)) ...
            '.tif'],'Compression','none');
    end
end

toc
disp('---');
disp('I am done!');
disp('---');