
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
imgtoread = 5;
rownumber = 512;
adjustbrightness = 0;
showsingleimages = 1;
showrows = 0;
showrowplots = 1;
showconcatenatedimages = 1;
writeas = 'pdf';
writefigures = 0; 

%% generally, there is no need to change anything below this line!


%% Setup
Data(1) = struct('Protocol', 'A', 'positions', ['lf';'ct';'rt'], ...
    'dark_im', [], 'flat_im', [], ...
    'left_im', [], 'center_im' , [] , 'right_im' , [], ...
    'left_row', [], 'center_row', [], 'right_row', [], ...
    'left_row_pad', [], 'center_row_pad', [], 'right_row_pad', [], ...
    'LCcorr', [], 'LCcorr_max', [], 'LCcorr_max_idx', [], ...
    'CRcorr', [], 'CRcorr_max', [], 'CRcorr_max_idx', [], ...
    'x1', [],  'x2', [], ...
    'max_brightness', [],  'concat_im', [], 'concat_im_corr', []);
Data(2) = struct('Protocol', 'B', 'positions', ['rg';'ct';'rg'], ...
    'dark_im', [], 'flat_im', [], ...
    'left_im', [], 'center_im' , [] , 'right_im' , [], ...
    'left_row', [], 'center_row', [], 'right_row', [], ...
    'left_row_pad', [], 'center_row_pad', [], 'right_row_pad', [], ...
    'LCcorr', [], 'LCcorr_max', [], 'LCcorr_max_idx', [], ...
    'CRcorr', [], 'CRcorr_max', [], 'CRcorr_max_idx', [], ...
    'x1', [],  'x2', [], ...
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
        
        loadimage = [ path '/' name '/' dir '/' name sprintf('%04d',imagenumber) '.tif' ]
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
            disp('I just flipped the 180° image of protocol B, so everything worked up to now');
        end
        %
    end
    
    Data(protocolcounter).left_row   = Data(protocolcounter).left_im(rownumber,:);
    Data(protocolcounter).center_row = Data(protocolcounter).center_im(rownumber,:);
    Data(protocolcounter).right_row  = Data(protocolcounter).right_im(rownumber,:);
        
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
    % Left - Center
%    Data(protocolcounter).left_row  = fliplr(Data(protocolcounter).left_row);
        
    Data(protocolcounter).left_row_pad   = [ Data(protocolcounter).left_row zeros(1,length(Data(protocolcounter).center_row)) ];
    Data(protocolcounter).center_row_pad = [ zeros(1,length(Data(protocolcounter).left_row )) Data(protocolcounter).center_row ];
        
 %   Data(protocolcounter).left_row_pad  = fliplr(Data(protocolcounter).left_row_pad);
    
    Data(protocolcounter).left_row_pad = Data(protocolcounter).left_row_pad';
    Data(protocolcounter).center_row_pad = Data(protocolcounter).center_row_pad';
   
%     Data(protocolcounter).LCcorr = ifft(fft(xcorr(Data(protocolcounter).center_row_pad,Data(protocolcounter).left_row_pad)));
    Data(protocolcounter).LCcorr = ifft(conj(fft(Data(protocolcounter).left_row_pad') .* fft(Data(protocolcounter).center_row_pad'))) ...
        ./ length(Data(protocolcounter).center_row_pad) .^2 ...
        ./ std(Data(protocolcounter).center_row) ...
        ./ std(Data(protocolcounter).right_row);
     
    [ Data(protocolcounter).LCcorr_max,Data(protocolcounter).LCcorr_max_idx ] = max( Data(protocolcounter).LCcorr );
    
    figure
        plot(Data(protocolcounter).LCcorr)
        title(['ifft(conj(fft(left,center))) for protocol ' Data(protocolcounter).Protocol ', with a maximum @ ' num2str(Data(protocolcounter).LCcorr_max_idx) ' px.'])
%     figure
%         plot(Data(protocolcounter).x2) 
%         title(['ifft(conj(fft(left) * fft(center))) for protocol ' Data(protocolcounter).Protocol ])

    % Center - Right
%    Data(protocolcounter).right_row = fliplr(Data(protocolcounter).right_row)
        
    Data(protocolcounter).center_row_pad = [ zeros(1,length(Data(protocolcounter).right_row)) Data(protocolcounter).center_row ];
    Data(protocolcounter).right_row_pad  = [ Data(protocolcounter).right_row zeros(1,length(Data(protocolcounter).center_row)) ];
    
%    Data(protocolcounter).right_row_pad = fliplr(Data(protocolcounter).right_row_pad)
    
    Data(protocolcounter).center_row_pad = Data(protocolcounter).center_row_pad';
    Data(protocolcounter).right_row_pad = Data(protocolcounter).right_row_pad';
    
%     Data(protocolcounter).CRcorr = ifft(fft(xcorr(Data(protocolcounter).center_row_pad,Data(protocolcounter).right_row_pad)));
    Data(protocolcounter).CRcorr = ifft(conj(fft(Data(protocolcounter).center_row_pad') .* fft(Data(protocolcounter).right_row_pad'))) ...
        ./ length(Data(protocolcounter).center_row_pad) .^2 ...
        ./ std(Data(protocolcounter).center_row) ...
        ./ std(Data(protocolcounter).right_row);
          
    [ Data(protocolcounter).CRcorr_max,Data(protocolcounter).CRcorr_max_idx ] = max( Data(protocolcounter).CRcorr );
    
    figure
        plot(Data(protocolcounter).CRcorr)
        title(['ifft(conj(fft(center,right))) for protocol ' Data(protocolcounter).Protocol ', with a maximum @ ' num2str(Data(protocolcounter).CRcorr_max_idx) ' px.'])
    %figure
    %    plot(Data(protocolcounter).x2) 
    %    title(['ifft(conj(fft(center) * fft(right))) for protocol ' Data(protocolcounter).Protocol ])
end

disp('---');
disp('I am now showing the concatenated images');
disp('---');

%% adjust the brightness of all the images to [0:1]
if adjustbrightness == 1
    for protocolcounter = 1:2
        % bring to zero
        Data(protocolcounter).left_im   = Data(protocolcounter).left_im   - min( min( Data(protocolcounter).left_im ) );
        Data(protocolcounter).center_im = Data(protocolcounter).center_im - min( min ( Data(protocolcounter).center_im ) );
        Data(protocolcounter).right_im  = Data(protocolcounter).right_im  - min( min( Data(protocolcounter).right_im ) );     

        % divide to one
        Data(protocolcounter).left_im = Data(protocolcounter).left_im ./ max( max( Data(protocolcounter).left_im ) );
        Data(protocolcounter).center_im = Data(protocolcounter).center_im ./ max( max( Data(protocolcounter).center_im ) );
        Data(protocolcounter).right_im = Data(protocolcounter).right_im ./ max( max( Data(protocolcounter).right_im ) );     
    end
end

    
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

for protocolcounter=1:2
    disp(Data(protocolcounter).Protocol);
    LCcorrMaxIdx=Data(protocolcounter).LCcorr_max_idx
    CRcorrMaxIdx=Data(protocolcounter).CRcorr_max_idx
    leftimsize = size(Data(protocolcounter).left_im)
    centerimsize=size(Data(protocolcounter).center_im)
    rightimsize=size(Data(protocolcounter).right_im)
end
    
    
%% concatenate the images correctly (leave away overlap)
for protocolcounter = 1:2
    Data(protocolcounter).concat_im_corr = [ Data(protocolcounter).left_im(:,1:(round(Data(protocolcounter).LCcorr_max_idx/2))) Data(protocolcounter).center_im Data(protocolcounter).right_im(:,round(Data(protocolcounter).CRcorr_max_idx/2):1024) ];
    if showconcatenatedimages == 1
        figure
            imshow(Data(protocolcounter).concat_im_corr,[])
            title(['corrected concatenated image for protocol ' Data(protocolcounter).Protocol])
    end
end

toc
disp('---');
disp('I am done!');
disp('---');