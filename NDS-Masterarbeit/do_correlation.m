
%% calculates correlation between imageoverlaps to see how much we have to
%% crop the images on each side.
%% 2008-07-18 initial version
%% 2008-07-21 started to work on own correlation-mode, since xcorr doesn't
%% work as intende
%% 2008-07-25 tried to implement my own correlation

%% Clear Workspace
clear;
clc;
close all;
tic; % start timer


%% setup 
path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2';
sample = 'R108C60_22202_';
dir = 'tif';
imagenumber = 5;
rownumber = 512;
showsingleimages = 0;
showconcatenatedimages = 1;

%% generally, there is no need to change anything below this line!


%% Setup the stuff in a structure
Structure(1) = struct('Protocol', 'A', 'suffixes', ['lf';'ct';'rt'], ...
    'left_im', [], 'center_im' , [] , 'right_im' , [], 'aux_im', [],...
    'left_row', [], 'center_row', [], 'right_row', [], 'aux_row', [], ...
    'correlation', [] );
Structure(2) = struct('Protocol', 'B', 'suffixes', ['rg';'ct';'rg'], ...
    'left_im', [], 'center_im' , [] , 'right_im' , [], 'aux_im', [], ...
    'left_row', [], 'center_row', [], 'right_row', [], 'aux_row', [], ...
    'correlation', [] );

%% load images
%load a
for protocolcounter = 1:2
    for positioncounter = 1:3
        name = [ sample Structure(protocolcounter).Protocol ...
            '_' Structure(protocolcounter).suffixes(positioncounter,:) ];
        imagenumber = 5;
        % if at 180+ of B, then increase the imagecounter to 180+...
            if protocolcounter == 2 && positioncounter == 1
                imagenumber = imagenumber + 3000;
            end
        %
        
        loaddarkimage = [ path '/' name '/' dir '/' name '0001.tif' ];
        darkimage = double(imread(loaddarkimage));
        
        loadflatimage  = [ path '/' name '/' dir '/' name '0003.tif' ];
        flatimage = double(imread(loadflatimage));
        flatimage = log(flatimage - darkimage);
        
        loadimage = [ path '/' name '/' dir '/' name sprintf('%04d',imagenumber) '.tif' ];
        image = double(imread(loadimage));
        image = flatimage - log(image - darkimage );
        
        if showsingleimages == 1
            figure
                imshow(darkimage,[])
                title(['dark ' Structure(protocolcounter).Protocol])
            figure
                imshow(flatimage,[])
                title(['flat ' Structure(protocolcounter).Protocol])
            figure
                imshow(image,[])
                title(['image ' Structure(protocolcounter).Protocol])
        end
              
        if positioncounter == 1
            Structure(protocolcounter).left_im = image;
        elseif positioncounter == 2
            Structure(protocolcounter).center_im = image;
        elseif positioncounter == 3
            Structure(protocolcounter).right_im = image;
        end
        % flip left image of Protocol B, so we can concatenate lateron...
            if protocolcounter == 2 && positioncounter == 1
                Structure(protocolcounter).left_im = fliplr(Structure(protocolcounter).left_im);
            end
        %
    end
    
    name = [ sample Structure(protocolcounter).Protocol ...
            '_' Structure(protocolcounter).suffixes(2,:) ]; % load from center (2) again!
    loadauximage = [ path '/' name '/' dir '/' name sprintf('%04d',imagenumber+3000) '.tif' ];
    auximage = double(imread(loadauximage));
    auximage = flatimage - log(auximage - darkimage );
    Structure(protocolcounter).aux_im = auximage;
    
    Structure(protocolcounter).left_row = Structure(protocolcounter).left_im(rownumber,:);
    Structure(protocolcounter).center_row = Structure(protocolcounter).center_im(rownumber,:);
    Structure(protocolcounter).right_row = Structure(protocolcounter).right_im(rownumber,:);
    
    Structure(protocolcounter).aux_row = Structure(protocolcounter).aux_im(rownumber,:);
end

%% pad images with zeroes, to calculate the correlation
% zerorow = zeros(1,size(Structure(1).center_row,2)*3);
% for protocolcounter = 1:2
%     tempcenterrow = Structure(protocolcounter).center_row;
%     Structure(protocolcounter).center_row = zerorow;
%     Structure(protocolcounter).center_row(1,1025:2048) = tempcenterrow;
%     
%     temprightrow = Structure(protocolcounter).right_row;
%     Structure(protocolcounter).right_row = zerorow;
%     Structure(protocolcounter).right_row(1,1025:2048) = temprightrow;
%     
%     figure
%         imshow(Structure(protocolcounter).center_row,[]);
%         title([Structure(protocolcounter).Protocol ' - center row'])
%     figure
%         plot(Structure(protocolcounter).center_row)
%         title([Structure(protocolcounter).Protocol ' - center row'])
%     figure
%         imshow(Structure(protocolcounter).right_row,[]);
%         
%         title([Structure(protocolcounter).Protocol ' - right row'])
%     figure
%         plot(Structure(protocolcounter).center_row)
%         title([Structure(protocolcounter).Protocol ' - right row'])
% end



%% compute correlation
%% A
% disp('-----A-----')
% %Structure(1).correlation  = xcorr(Structure(1).center_row,fliplr(Structure(1).right_row));
% Structure(1).correlation  = xcorr(Structure(1).center_row,fliplr(Structure(1).aux_row));
% figure
%     plot(Structure(1).correlation)
%     title('correlation for Protocol A')
%         
% [stemcorrA,lagsA] = xcorr(Structure(1).center_row,fliplr(Structure(1).aux_row));
% % 
% % max(Structure(1).center_row - Structure(1).aux_row)
% max(Structure(1).aux_row - Structure(1).center_row)

% figure
%     stem(lagsA,stemcorrA)
%     title('stems for Protocol A')
% [corrmaxA,IA] = max(stemcorrA)
% pixelshift = (IA - 1024) / 2
     
% %% compute correlation
% %% B
% disp('-----B-----')
% Structure(1).correlation  = xcorr(Structure(1).center_row,fliplr(Structure(1).aux_row));
% figure
%     plot(Structure(1).correlation)
%     title('correlation for Protocol B')
%         
% [stemcorrB,lagsB] = xcorr(Structure(2).center_row,Structure(2).aux_row);
% figure
%     stem(lagsB,stemcorrB)
%     title('stems for Protocol B')
% [cfigure;imshow(fliplr(Structure(1).aux_row),[])orrmaxB,IB] = max(stemcorrB)
% pixelshift = (IA - 1024) / 2

figure
    imshow(Structure(1).left_im,[])
    title('left')
figure
    imshow(Structure(1).center_im,[])
    title('center')
figure
    imshow(Structure(1).right_im,[])
    title('right')
    
figure
    imshow(Structure(1).center_im-Structure(1).right_im)
    
%corr=xcorr(Structure(1).center_im,Structure(1).right_im)
%figure
%    plot(corr)

%% concatenate the images to show
ConcatenatedImageA = [ Structure(1).left_im Structure(1).center_im ...
    Structure(1).right_im ];
ConcatenatedImageB = [ Structure(2).left_im Structure(2).center_im ...
    Structure(1).right_im ];

if showconcatenatedimages == 1
    figure
        imshow(ConcatenatedImageA,[])
        title('concatenated A')   
    figure
        imshow(ConcatenatedImageB,[])
        title('concatenated B')
end



%% plot

%% crop bigger images (instead of padding smaller)


toc

