clc;

%% Set Parameters
SampleName = 'R108C60_22_20x_';
resize = 0.25;

%% define Names and such
ProtocolName =   [ 'A', 'B',   'C', 'D', 'E', 'F'];
RotCenter =     [ 1532,1538.5,1539,1539,1537,1539];
sins = [1,256,511,512,766,768,1021,1023];
path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/';

%% perform the reconstruction
for whichone=1:1 %2:6 % %1=a 2=b 3=c 4=d 5=e 6=f
    addpath = '';
    tic;
    for counter = 1:size(sins,2) % which sinogram should we read?
        %% generate FileNumber for Reconstruction
        FileNumber = sins(counter);
        
        %% define Filename
        Filename=[SampleName ProtocolName(whichone) '_conc' ];
        
        %% inform user what's going on
        disp(['reconstructing sinogram ' num2str(FileNumber) ' of protocol '...
            num2str(ProtocolName(whichone)) ' with a Rotation Center of ' ...
            num2str(RotCenter(whichone)) ' pixels.']);

        %% setup and make necessary directories
        recdir = [path Filename '/rec' addpath '/'];
        sindir = [path Filename '/sin' addpath '/'];
        tifdir = [path Filename '/tif' addpath '/'];
        FileNumberStr = [ sprintf('%04d',FileNumber)];
        RecFilename = [Filename FileNumberStr '.rec.DMP'];
  
        %supress directory already exists message....
        [s,mess,messid]=mkdir([recdir]);

        %% compute inverse radon transformation with sin2rec on console
        command = ['sin2rec2 ' sindir Filename FileNumberStr '.sin.DMP '...
            recdir ' ' sprintf('%4.2f',RotCenter(whichone)) ' 0.0 0 0 0 0 4 10 0.6 0 0 0 0 0.0 0.0']
        system(command)
        
        %% 
        disp('done');
    end
    toc;
    disp( '----------------------------');
    disp(['--- done with protocol ' num2str(ProtocolName(whichone)) ' ---']);
    disp( '----------------------------');
end

%% display images (for last calculated slice)
path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/';
figure('Name',['Reconstructions for Slice ' num2str(FileNumber)], 'NumberTitle','off');
    for Protocol =1:6
        readfile = [ path SampleName ProtocolName(Protocol) '_conc/rec/' ...
            SampleName ProtocolName(Protocol) '_conc' sprintf('%04d',FileNumber) '.rec.DMP' ];
        subplot(2,3,Protocol)
            imagesc(readDumpImage(readfile));
            title(num2str(ProtocolName(Protocol)));
            colormap gray;
            axis image;
    end
    
disp('Finished with everything you asked for.');
    