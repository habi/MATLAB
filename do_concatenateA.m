clear;
clc;
close all;

%% 2008.06.09 added stripe for comparison with other reconstructions, watch
%% out for it on line 54 if you use this!

%% Set Parameters
dowriteConcatenatedImage = 1;

from = 740;
to = 3001;

%% general stuff
ProtocolName = ['A'];
ProtocolFilenames = str2mat('lf', 'ct', 'rt');
NumProj= 3001;
File = 'R108C60_22_20x_';
Filename = [File 'A'];
path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/';
savedir = [path '_conca/' Filename '_conc'];
[s,mess,messid]=mkdir([ savedir ]);
[s,mess,messid]=mkdir([ savedir '/tif' ]);
[s,mess,messid]=mkdir([ savedir '/sin' ]);

%% Darks and Flats
% 1=center, 2=ring
loaddir = [path Filename '_' ProtocolFilenames(2,:) '/tif'];
FileName = [loaddir '/' Filename '_' ProtocolFilenames(2,:) '0001.tif'];
DarkImage = single(imread(FileName));
FileName = [loaddir '/' Filename '_' ProtocolFilenames(2,:) '0003.tif'];
FlatImage = single(imread(FileName));
FlatImage = log(FlatImage-DarkImage);

%% h_ConcImgRing(File,NumProjCenter,NumProjRing)
tic;

progress = waitbar(0,['crunching numbers for protocol ' num2str(ProtocolName) ', please wait...']);
 
for ImageNumber = from:to;
    
    for whichone = 1:3 %iterate from left to center to right...
        FileNumberStr = [ sprintf('%04d',ImageNumber+4)];
        loaddir = [path Filename '_' ProtocolFilenames(whichone,:) '/tif'];
        I = [loaddir '/' Filename '_' ProtocolFilenames(whichone,:) FileNumberStr '.tif'];
        Image = single(imread(I));
        Image = log(Image - DarkImage);
        Image = FlatImage - Image;
        TmpImg(:,:,whichone) = Image;
    end

    % adds a stripe, so we can compare
    TmpImg(:,size(TmpImg(:,:,1),1):size(TmpImg(:,:,1),1),1) = mean(mean(TmpImg(:,:,1)));
    
    ConcatenatedImage = [ TmpImg(:,:,1) TmpImg(:,:,2) TmpImg(:,:,3) ];
    ConcatenatedImage = ConcatenatedImage - min(min(ConcatenatedImage));
    ConcatenatedImage = ConcatenatedImage / max(max(ConcatenatedImage));
    
%     figure(1);
%          imshow(ConcatenatedImage,[]);
%          title(['A /' num2str(FileNumberStr)]);
   waitbar(ImageNumber/to);
   
   disp(['Concatenating Images ' num2str(ImageNumber) ' of ' num2str(to) '...']);
   
   ImageNumberStr = [ sprintf('%04d',ImageNumber)];
   if dowriteConcatenatedImage == 1
       imwrite(ConcatenatedImage,[savedir '/tif/' Filename '_conc' ImageNumberStr '.tif'],...
           'Compression','none');
       % Compression none, so that ImageJ can read the tiff-files...
   else
   end

 
  %% Clear stuff that is not used anymore....
  clear ConcatenatedImage;
  clear TmpImg;
  clear Image;
end
  
close(progress);
toc;
disp( '----------------------------');
disp(['--- done with protocol ' num2str(ProtocolName) ' ---']);
disp( '----------------------------');