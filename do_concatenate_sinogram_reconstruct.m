clear;
clc;
close all;

for whichone=5:5
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
    addtosavedir = ''; 
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

    from = 1;
    numimages = ((ProtocolNumProjRing(whichone)-1)/2)+1;
    to = numimages;
%     to = from + 3;

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
            ImageRFlip = [ mean(ImageRFlip,2)*ones(1,AddToFlippedImage) ImageRFlip ];
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
        
        %% Clear stuff that is not used anymore....
        clear ConcatenatedImage;
        clear ImageC;
        clear ImageR;
        clear ImageRFlip;
        
    end
    
    %% compute sinograms with prj2sin `on the fly`
    command = ['prj2sin ' savedir '/tif' addtosavedir '/' Filename '_conc####.tif -g 0 -f '...
       num2str(((ProtocolNumProjRing(whichone)-1)/2)+1) ',0,0,0,0 -d -j ' num2str(255) ' -r 0,0,0,0 -o ' ...
       savedir '/sin' addtosavedir '/' ]
    system(command);
    command = ['prj2sin ' savedir '/tif' addtosavedir '/' Filename '_conc####.tif -g 0 -f '...
       num2str(((ProtocolNumProjRing(whichone)-1)/2)+1) ',0,0,0,0 -d -j ' num2str(511) ' -r 0,0,0,0 -o ' ...
       savedir '/sin' addtosavedir '/' ]
    system(command);
    command = ['prj2sin ' savedir '/tif' addtosavedir '/' Filename '_conc####.tif -g 0 -f '...
       num2str(((ProtocolNumProjRing(whichone)-1)/2)+1) ',0,0,0,0 -d -j ' num2str(767) ' -r 0,0,0,0 -o ' ...
       savedir '/sin' addtosavedir '/' ]
    system(command);
    
    %% finish
    
    close(progress);
    
    toc;
    
    disp( '----------------------------');
    disp(['--- done with protocol ' num2str(ProtocolName(whichone)) ' ---']);
    disp( '----------------------------');
    
end

disp('Finished with concatenating and sinogram generation, proceeding to reconstruction...');

clear all;

%% perform Reconstruction
SampleName = 'R108C60_22_20x_';

%% define Names and such
ProtocolName =   [ 'A', 'B', 'C', 'D', 'E', 'F'];
RotCenter =     [ 1534,1534,1534,1534,1534,1534];
sins = [1,256,511,512,766,768,1021,1023];

%% perform the reconstruction
for whichone=1:length(ProtocolName)
    addpath = '';   % dummy
    resize = 1;     % dummy!
    tic;
    for counter = 1:length(sins) % which sinogram should we read?
        %% generate FileNumber for Reconstruction
        FileNumber = sins(counter);
        %% define Filename
        Filename=[SampleName ProtocolName(whichone) '_conc' ];
        %% inform user what's going on
        disp(['reconstructing sinogram ' num2str(FileNumber) ' of protocol '...
            num2str(ProtocolName(whichone)) ' with a Rotation Center of ' ...
            num2str(RotCenter(whichone)) ' pixels.']);
        %% calculate
        h_Reconstruct(Filename,FileNumber,resize,RotCenter(whichone),addpath);
        disp('done');
    end
    
    toc;
    
    disp( '----------------------------');
    disp(['--- done with protocol ' num2str(ProtocolName(whichone)) ' ---']);
    disp( '----------------------------');
    
end

disp('if everything went smoot, the time is:');

time = clock

disp('Finished with everything you asked for, phew!');