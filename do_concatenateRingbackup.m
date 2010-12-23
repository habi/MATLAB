clear;
clc;
close all;

for whichone=1:5
    
    %% Set Parameters
    ProtocolName = ['B','C','D','E','F'];
    ProtocolFilenames = str2mat('ct', 'rg');
    ProtocolNumProjCenter = [3001 1501 1501 1001 1001];
    ProtocolNumProjRing   = [6001 6001 3001 4001 2001];
    Interpolate           = [1    2    1    2    1];
    
    Sample = 'R108C60_22_20x_';
    Filename = [ Sample ProtocolName(whichone) ];
    path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/';
    
    concdir = [ path '_conca/' Filename '/tif/' ];
    [status,message,messageid] = mkdir(concdir);
    sindir = [ path '_conca/' Filename '/sin/' ];
    [status,message,messageid] = mkdir(sindir);
   
    %% Darks and Flats
    % 1=center, 2=ring
    LoadName = [ Sample ProtocolName(whichone) '_' ProtocolFilenames(whichone,:) ];
    FileName = [ path LoadName '/tif/'  LoadName '0001.tif' ];
    DarkImage = single(imread(FileName));
    FileName = [ path LoadName '/tif/'  LoadName '0003.tif' ];
    FlatImage = single(imread(FileName));
    FlatImage = log(FlatImage-DarkImage);

    from = 1;
    to = ((ProtocolNumProjRing(whichone)-1)/2)+1;
    to = from + 3;
    
    disp(['Concatenating Protocol ' num2str(ProtocolName(whichone)) ...
        ', Images ' num2str(from) ' to ' num2str(to) '...']);
%     progress = waitbar(0,['crunching numbers for protocol ' ...
%         num2str(ProtocolName(whichone)) ', please wait...']);
    
    loaddir = [path Filename '_' ProtocolFilenames(1,:) '/tif'];
    C = [loaddir '/' Filename '_' ProtocolFilenames(1,:) '0005.tif'];
    CenterNextImage = single(imread(C));
    CenterPrevImage = CenterNextImage;
    
    tic;
    
    TempCounter=1;
    
    for ImageNumber = from:to;
        
        %%Center
        Modulo = mod(ImageNumber-1,Interpolate(whichone));
        
        if Modulo == 0
            ImageNumberCenter = ceil(ImageNumber/Interpolate(whichone))+1;
            ImageNumberCenterStr = [ sprintf('%04d',ImageNumberCenter+4)];
            loaddir = [path Filename '_' ProtocolFilenames(1,:) '/tif'];
            CenterPrevImage = CenterNextImage;
            C = [loaddir '/' Filename '_' ProtocolFilenames(1,:) ImageNumberCenterStr '.tif'];
            CenterNextImage = single(imread(C));
            ImageC=CenterPrevImage;
        else
            InterpolationCoeff = Modulo/Interpolate(whichone);
            ImageC = CenterPrevImage.*(1-InterpolationCoeff)+CenterNextImage.*InterpolationCoeff;
        end
        ImageC = log(ImageC - DarkImage);
        ImageC = FlatImage - ImageC;
        TmpImg(:,:,1) = ImageC;

        %% start Ring
        ImageNumberStr = [sprintf('%04d',ImageNumber+4)];
        loaddir = [path Filename '_' ProtocolFilenames(2,:) '/tif'];
        R = [loaddir '/' Filename '_' ProtocolFilenames(2,:) ImageNumberStr '.tif'];
        ImageR = single(imread(R));
        ImageR = log(ImageR - DarkImage);
        ImageR = FlatImage - ImageR;
        TmpImg(:,:,2) = ImageR;
        %     figure(2);
        %         imshow(ImageR,[]);

        %% start+180 Ring
        FlipImageNumber = ImageNumber + ((ProtocolNumProjRing(whichone)-1)/2);
        FlipImageNumberStr = [ sprintf('%04d',FlipImageNumber+4)];
        RFlip = [loaddir '/' Filename '_' ProtocolFilenames(2,:) FlipImageNumberStr '.tif'];
        ImageRFlip = single(imread(RFlip));
        ImageRFlip = log(ImageRFlip - DarkImage);
        ImageRFlip = FlatImage - ImageRFlip;
        ImageRFlip = fliplr(ImageRFlip);
        TmpImg(:,:,3) = ImageRFlip;
        %     figure(3);
        %         imshow(ImageRFlip,[]);

        ConcatenatedImage = [ TmpImg(:,:,3) TmpImg(:,:,1) TmpImg(:,:,2) ];
        ConcatenatedImage = ConcatenatedImage - min(min(ConcatenatedImage));
        ConcatenatedImage = ConcatenatedImage / max(max(ConcatenatedImage));
        %         figure(4);
        %             imshow(ConcatenatedImage,[]);
        %             title([num2str(ProtocolName(whichone)) '/' num2str(ImageNumberStr)]);

        waitbar((ImageNumber-from)/(to-from));
        ImageNumberStr = [sprintf('%04d',ImageNumber)];
        
        %%% TEMPORARY TO TEST SINOGRAM-GENERATION
        %ImageNumber=TempCounter;
        %ImageNumberStr = [sprintf('%04d',TempCounter)];
        %%% TEMPORARY TO TEST SINOGRAM-GENERATION
    
        disp(['Concatenating Images Nr. ' num2str(ImageNumber) '...']);
        imwrite(ConcatenatedImage,[concdir '/' Filename '_conc' ImageNumberStr '.tif'],...
            'Compression','none');
        % Compression none, so that ImageJ can read the tiff-files...
     
        %%% TEMPORARY TO TEST SINOGRAM-GENERATION
        %TempCounter=TempCounter+1;
        %%% TEMPORARY TO TEST SINOGRAM-GENERATION

        %%Accumulate three Sinograms on the fly
        SinogramRow1=256;
        Sinogram1(ImageNumber,:) = ConcatenatedImage(SinogramRow1,:);
        SinogramRow2=512;
        Sinogram2(ImageNumber,:) = ConcatenatedImage(SinogramRow2,:);
        SinogramRow3=768;
        Sinogram3(ImageNumber,:) = ConcatenatedImage(SinogramRow3,:);
        
        %% Clear stuff that is not used anymore....
        clear ConcatenatedImage;
        clear TmpImg;
        clear ImageC;
        clear ImageR;
        clear ImageRFlip;
    end
    
%     figure;
%         imshow(Sinogram2,[]);
%         title(['One Sinogram for Protocol ' num2str(ProtocolName(whichone)) ' and Image ' num2str(SinogramRow2)]);
    SinogramRow1Str = [ sprintf('%04d',SinogramRow1)]; 
    imwrite(Sinogram1,[sindir '/' Filename '_conc' num2str(SinogramRow1Str) '.sin.tif'],...
        'Compression','none');
    SinogramRow2Str = [ sprintf('%04d',SinogramRow2)];
    imwrite(Sinogram2,[sindir '/' Filename '_conc' num2str(SinogramRow2Str) '.sin.tif'],...
        'Compression','none');
    SinogramRow3Str = [ sprintf('%04d',SinogramRow3)];
    imwrite(Sinogram3,[sindir '/' Filename '_conc' num2str(SinogramRow3Str) '.sin.tif'],...
        'Compression','none');
    
    disp(['Sinograms have been written to: ' num2str(sindir)]);
    
    close(progress);
    toc;
    disp( '----------------------------');
    disp(['--- done with protocol ' num2str(ProtocolName(whichone)) ' ---']);
    disp( '----------------------------');
    
end