
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

imgtoread = 1024;

adjustbrightness = 0;
showsingleimages = 0;
showrows = 0;
showrowplots = 0;
showcorrelations = 0;
showconcatenatedimages = 1;
showcorrconcatenatedimages = 1;
overlap = 111;

writeas = 'pdf';
writefigures = 0; 
writeimages = 0;

nrows = 128;
stepwidth = 1;
maxsearchrange = .5;

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
            disp('I just flipped the 180degree image of protocol B, so everything worked up to now');
        end
        %
    end

end

disp('---');
disp('I loaded all images, and show them now if desired');
disp('---');

%% concatenate the images
for protocolcounter = 1:2
    Data(protocolcounter).concat_im = [ Data(protocolcounter).left_im Data(protocolcounter).center_im Data(protocolcounter).right_im ];
    if showconcatenatedimages == 1
        figure
            imshow(Data(protocolcounter).concat_im,[])
            title(['concatenated image for protocol ' Data(protocolcounter).Protocol])
            axis on
    end


%% merge images

    Projections(1) = struct('slicedata',Data(protocolcounter).left_im);
    Projections(2) = struct('slicedata',Data(protocolcounter).center_im);
    Projections(3) = struct('slicedata',Data(protocolcounter).right_im);
    cutlines = merge_test_new(Projections,nrows,stepwidth,maxsearchrange)
    
    disp('---');
    disp('I am now showing the concatenated images with overlap');
    disp('---');


%% concatenate the images correctly (leave away overlap)
    Data(protocolcounter).concat_im_corr = [ 
        Projections(1).slicedata ...
        Projections(2).slicedata(:,cutlines(1):size(Projections(2).slicedata,2)) ...
        Projections(3).slicedata(:,cutlines(2):size(Projections(2).slicedata,2)) ];
    if showcorrconcatenatedimages == 1
        figure
            imshow(Data(protocolcounter).concat_im_corr,[])
            title(['corrected concatenated image for protocol ' Data(protocolcounter).Protocol])
            axis on
    end
end

% if writeimages ==1
%         Data(protocolcounter).concat_im_corr = Data(protocolcounter).concat_im_corr - min(min(Data(protocolcounter).concat_im_corr));
%         Data(protocolcounter).concat_im_corr = Data(protocolcounter).concat_im_corr ./ max(max(Data(protocolcounter).concat_im_corr));
%         
%         imwrite(Data(protocolcounter).concat_im_corr,['/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conatenate_overlap/' ...
%             Data(protocolcounter).Protocol '-img' num2str(sprintf('%04d',imgtoread)) ...
%             '.tif'],'Compression','none');

% close all

toc
disp('---');
disp('I am done!');
disp('---');