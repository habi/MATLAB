clear;
clc;
close all;

for whichone=1:5
    tic;
    
    dowriteConcatenatedImage = 1;
    dowriteSinograms = 1;
    
    %% Set Parameters
    ProtocolName = ['B','C','D','E','F'];
    ProtocolFilenames = str2mat('ct', 'rg');
    ProtocolNumProjCenter = [3001 1501 1501 1001 1001];
    ProtocolNumProjRing   = [6001 6001 3001 4001 2001];
    Interpolate           = [1    2    1    2    1];
    File = 'R108C60_22_20x_';
    Filename = [File ProtocolName(whichone)];
    path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/';
    savedir = [path '_conca/' Filename '_conc'];
    [s,mess,messid]=mkdir([ savedir ]);
    addtosavedir = '-rotcentershiftcorr'; 
    [s,mess,messid]=mkdir([ savedir '/tif' addtosavedir ]);
    [s,mess,messid]=mkdir([ savedir '/sin' addtosavedir ]);
    [s,mess,messid]=mkdir([ savedir '/rec' addtosavedir ]);
    
    %% Darks and Flats
    % 1=center, 2=ring
    loaddir = [path Filename '_' ProtocolFilenames(1,:) '/tif'];
    FileName = [loaddir '/' Filename '_' ProtocolFilenames(1,:) '0001.tif'];
    DarkImage = single(imread(FileName));
    FileName = [loaddir '/' Filename '_' ProtocolFilenames(1,:) '0003.tif'];
    FlatImage = single(imread(FileName));
    FlatImage = log(FlatImage-DarkImage);

    %% h_ConcImgRing(File,NumProjCenter,NumProjRing)

    from = 1;
    numimages = ((ProtocolNumProjRing(whichone)-1)/2)+1;
    to = numimages;
    to = from + 10;

    progress = waitbar(0,['crunching numbers for protocol ' num2str(ProtocolName(whichone)) ', please wait...']);

    loaddir = [path Filename '_' ProtocolFilenames(1,:) '/tif'];
    C = [loaddir '/' Filename '_' ProtocolFilenames(1,:) '0005.tif'];
    CenterNextImage = single(imread(C));
    CenterPrevtImage = CenterNextImage;

    for ImageNumber = from:to

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

        %% start Ring
        ImageNumberStr = [sprintf('%04d',ImageNumber+4)];
        
        loaddir = [path Filename '_' ProtocolFilenames(2,:) '/tif'];
        R = [loaddir '/' Filename '_' ProtocolFilenames(2,:) ImageNumberStr '.tif'];
        ImageR = single(imread(R));
        ImageR = log(ImageR - DarkImage);
        ImageR = FlatImage - ImageR;

        %% start+180 Ring
        FlipImageNumber = ImageNumber + numimages -1;
        FlipImageNumberStr = [ sprintf('%04d',FlipImageNumber+4)];
        RFlip = [loaddir '/' Filename '_' ProtocolFilenames(2,:) FlipImageNumberStr '.tif'];
        ImageRFlip = single(imread(RFlip));
        ImageRFlip = log(ImageRFlip - DarkImage);
        ImageRFlip = FlatImage - ImageRFlip;
        
        ImageMiddle = ( size(ImageRFlip,1) / 2 );
        RotCenterDifference = ImageMiddle - 510;
        AddToFlippedImage = 2 * RotCenterDifference;

        % correct for RotationCenterShift
        if AddToFlippedImage < 0
            ImageRFlip = ImageRFlip(:,abs(AddToFlippedImage)+1:size(ImageRFlip,1));
        elseif AddToFlippedImage > 0
            ImageRFlip = [ mean(mean(ImageRFlip)).*ones(size(ImageRFlip,2),AddToFlippedImage) ImageRFlip ];
        end
            
        ImageRFlip = fliplr(ImageRFlip);

        ConcatenatedImage = [ ImageRFlip ImageC ImageR ];
        ConcatenatedImage = ConcatenatedImage - min(min(ConcatenatedImage));
        ConcatenatedImage = ConcatenatedImage / max(max(ConcatenatedImage));
        
        waitbar((ImageNumber-from)/(to-from));
        ImageNumberStr = [sprintf('%04d',ImageNumber)];
        
        disp(['Concatenating Images Nr. ' num2str(ImageNumber) '...']);
        if dowriteConcatenatedImage == 1
            imwrite(ConcatenatedImage,[savedir '/tif' addtosavedir '/' Filename '_conc' ImageNumberStr '.tif'],...
                'Compression','none');
            % Compression none, so that ImageJ can read the tiff-files...
        else
        end
%         
        %% Clear stuff that is not used anymore....
        clear ConcatenatedImage;
        clear ImageC;
        clear ImageR;
        clear ImageRFlip;
    end
    %% compute sinograms with prj2sin
    command = ['prj2sin ' savedir '/tif' addtosavedir '/' Filename '_conc####.tif -g 0 -f '...
       ((ProtocolNumProjRing(whichone)-1)/2)+1 ',0,0,0,0 -d -j ' 255 ' -r 0,0,0,0 -o ' ...
       savedir '/sin' addtosavedir '/' ]
    system(command);
    command = ['prj2sin ' savedir '/tif' addtosavedir '/' Filename '_conc####.tif -g 0 -f '...
       ((ProtocolNumProjRing(whichone)-1)/2)+1 ',0,0,0,0 -d -j ' 511 ' -r 0,0,0,0 -o ' ...
       savedir '/sin' addtosavedir '/' ]
    system(command);
    command = ['prj2sin ' savedir '/tif' addtosavedir '/' Filename '_conc####.tif -g 0 -f '...
       ((ProtocolNumProjRing(whichone)-1)/2)+1 ',0,0,0,0 -d -j ' 767 ' -r 0,0,0,0 -o ' ...
       savedir '/sin' addtosavedir '/' ]
    system(command);
    
    %% finish
    
    close(progress);
    toc;
    disp( '----------------------------');
    disp(['--- done with protocol ' num2str(ProtocolName(whichone)) ' ---']);
    disp( '----------------------------');
    
end