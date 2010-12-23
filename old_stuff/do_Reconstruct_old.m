clc;
close all;

%% Set Parameters
SampleName = 'R108C60_22_20x_';
resize = 0.25;

%% define Names and such
ProtocolName =   [ 'A','B','C','D','E','F'];
RotCenter = 3072/2;
RotCenterShift = [  round(((1534.00 + 1534.00 + 1534.00)/3)-RotCenter),... % A
                    round(((1537.00 + 1537.00 + 1537.00)/3)-RotCenter),... % B
                    round(((1537.00 + 1537.00 + 1537.00)/3)-RotCenter),... % C
                    round(((1537.00 + 1536.98 + 1537.00)/3)-RotCenter),... % D
                    round(((1537.00 + 1536.56 + 1537.00)/3)-RotCenter),... % E
                    round(((1537.00 + 1537.00 + 1537.00)/3)-RotCenter),... % F
                  ];

sins = [1,256,511,512,766,768,1021,1023];


%% perform the reconstruction
for whichone=1:6 %1=a 2=b 3=c 4=d 5=e 6=f
    tic;
    for counter = 1:8 % which sinogram should we read?
        %% generate FileNumber for Reconstruction
        FileNumber = sins(counter);
        %% define Filename
        Filename=[SampleName ProtocolName(whichone) '_conc' ];
        %% inform user what's going on
        disp(['reconstructing sinogram ' num2str(FileNumber) ' of protocol '...
            num2str(ProtocolName(whichone)) ' while shifting it ' ...
            num2str(RotCenterShift(whichone)) ' pixels.']);
        %% calculate
        h_Reconstruct(Filename,FileNumber,resize,RotCenterShift(whichone));
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
            SampleName ProtocolName(Protocol) '_conc' sprintf('%04d',FileNumber) '.rec.tif' ];
        subplot(2,3,Protocol)
            imagesc(imread(readfile));
            title(num2str(ProtocolName(Protocol)));
            colormap gray;
            axis image;
    end
    
disp('Finished with everything you asked for.');
    