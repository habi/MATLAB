clear;close all;clc;
warning off Images:initSize:adjustingMag;

whichProtocol = 2;
whichSlice    = 16;

writeSlices = 1;
writeDifferenceImage = 1;

takesample = 0             % take only sample-part of image
takecentral = 0            % take only central part of scan
normalize = 0              % normalize images to [0:1] instead of [-something:something] ONLY GOOD FOR DMPs!
correctforrotation = 0     % correct for rotation (linearly from 0:-1.11133, as seen in "Winkelmessung2008c.tex"
thresholding = 1           % threshold input images using Otsu-thresholding
thresholdDiffImages = 0    % threshold the Difference-Images

angle = -1.11133*[1:19]/19;
ImageSize = [];

Protocols = ['b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t'];
%Protocols = Protocols(2:3:end)

if isunix == 1 
    UserID = 'e11126';
    %beamline
    whereamI = '/sls/X02DA/data/';
    %slslc05
    %whereamI = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/';
    PathToFiles = '/Data10/2008c/';    
    BasePath = fullfile( whereamI , UserID , PathToFiles );
    path = '/sls/X02DA/Data10/e11126/2008c/mrg/';
    addpath = 'P:\MATLAB\SRuCT';
    addpath([ whereamI UserID '/MATLAB'])
    addpath([ whereamI UserID '/MATLAB/SRuCT']) 
else
    whereamI = 'S:';
    PathToFiles = 'SLS/2008c/mrg/';
    path = fullfile(whereamI, PathToFiles);   
    addpath('P:\MATLAB')
    addpath('P:\MATLAB\SRuCT')
end

Slices = 1:50:1024; % every 50th sinogram is reconstructable with RecoManager
Slice = [ sprintf('%04d',Slices(whichSlice))];
SamplePrefix = 'R108C21C';
readDir = 'rec_8bit';suffix = 'rec.8bit';
%readDir = 'sin';suffix = readDir;

DMP = 0;
if DMP == 0
    Filetype='.tif';
elseif DMP == 1
    Filetype='.DMP';
end


for whichProtocol = 1:length(Protocols)
    file = [ path SamplePrefix Protocols(whichProtocol) '_mrg' filesep ...
       readDir filesep SamplePrefix Protocols(whichProtocol) '_mrg' ...
       Slice '.' suffix Filetype ];
    Filename = [ SamplePrefix Protocols(whichProtocol) '_mrg' Slice '.' suffix Filetype ];
    
    % displayDumpImage(file)   
    if DMP == 0
        image = imread(file);
    elseif DMP == 1
        image = readDumpImage(file);
    end
    
    if isempty(ImageSize)
        ImageSize = size(image);
    end
    
    image = imresize(image,ImageSize);
    
    
    rotationcorrection=50;
    rc=rotationcorrection;clear rotationcorrection; % so we have to write less...
    % take only part of image
    if takecentral ==1
        width = size(image,2);
        heigth = size(image,1);
        image = image(width/2-512-rc:width/2+512+rc,heigth/2-512-rc:heigth/2+512+rc);
    elseif takesample == 1
        width = size(image,2);
        heigth = size(image,1);
        third = round(width/3);
        image = image(third:2*third,512:end-256);
        correctforrotation = 0;
        disp('rotation-correction does not work if we take non-square part of sample');
    end
 
    disp([ Filename ' has a size of ' num2str(size(image,1)) 'x' num2str(size(image,2)) ' pixels.']);
    
    if normalize == 1
        image = image - min(min(image));
        image = image ./ max(max(image));
    end
     
    if thresholding == 1
        threshold = graythresh(image);
        image = im2bw(image,threshold);
    end
    
    if correctforrotation ==1
        image = imresize(imrotate(image,angle(whichProtocol)),[1024 NaN]);
        image = image(rc:end-rc,rc:end-rc);
    end

    figure
        imshow(image,[]);
        colormap gray
        axis on image
        title(Filename,'Interpreter','none')
        
    if writeSlices ==1
        writepath = [ path SamplePrefix Protocols(whichProtocol) '_mrg' filesep ...
            'MATLAB' filesep ];
        writefilename = [ SamplePrefix Protocols(whichProtocol) '_mrg' ...
           Slice '.' suffix Filetype ];
        [ s, mess, messid] = mkdir(writepath);
        imwrite(image,[writepath writefilename ],'Compression','none')
    end

    CollectedImages(:,:,:,whichProtocol) = image;

    %     figure
    %         imagesc(readDumpImage(file));
    %         colormap gray
    %         axis image 
    %         title([ num2str(Protocol(k)) ' slice ' Slice ])
    %    size(readDumpImage(file))
    %end
    
    %disp('pausing for 5 seconds...')
    %pause(5)
    %close;
end

%% compute DifferenceImage
disp('computing difference images')
figure;
w = waitbar(0,'computing difference images');
for whichProtocol = 1:length(Protocols)
    waitbar(whichProtocol/length(Protocols));
    DifferenceImages(:,:,:,whichProtocol) = CollectedImages(:,:,:,1) - CollectedImages(:,:,:,whichProtocol);
    % threshold DifferenceImages
    if thresholdDiffImages == 1
        threshold = graythresh(DifferenceImages(:,:,:,whichProtocol));
        DifferenceImages(:,:,:,whichProtocol) = im2bw(DifferenceImages(:,:,:,whichProtocol),threshold);
    end
    subplot(4,ceil(length(Protocols)/4),whichProtocol)
        imshow(DifferenceImages(:,:,:,whichProtocol),[])
        title(['DiffImg ' Protocols(whichProtocol)])
    
    if writeDifferenceImage == 1
        if normalize == 1
            DifferenceImages(:,:,:,whichProtocol) = DifferenceImages(:,:,:,whichProtocol) - min(min(DifferenceImages(:,:,:,whichProtocol)));
            DifferenceImages(:,:,:,whichProtocol) = DifferenceImages(:,:,:,whichProtocol) ./ max(max(DifferenceImages(:,:,:,whichProtocol)));
        end
        
        writepath = [ path SamplePrefix Protocols(whichProtocol) '_mrg' filesep ...
            'MATLAB' filesep ];
        writefilename = [ SamplePrefix Protocols(whichProtocol) '_mrg' ...
           Slice '.' suffix '.diff' Filetype ];
        imwrite(DifferenceImages(:,:,:,whichProtocol),[writepath writefilename ],'Compression','none');
    end
    AbsoluteError(whichProtocol) = sum( sum( DifferenceImages(:,:,:,whichProtocol) .^2 ) );
end
close(w);

ErrorPerPixel = AbsoluteError / ...
        ( size(DifferenceImages(:,:,:,whichProtocol),1) * size(DifferenceImages(:,:,:,whichProtocol),1) );

%x=(length(Protocols)+1)-(1:length(Protocols)); % Damit die Protokolle andersrum sortiert sind
%x=1:length(Protocols);                         % Damit die Protokolle in der Reihenfolge sortiert sind

close all;

figure
    montage(DifferenceImages)
    title('DifferenceImages')
figure
    montage(CollectedImages)
    title('CollectedImages')
    
figure
    plot(AbsoluteError,'-bo')
    set(gca,'XTick',[1:length(Protocols)])
    set(gca,'XTickLabel',rot90(fliplr(Protocols)))
    
disp('Finished with everything you asked for.');