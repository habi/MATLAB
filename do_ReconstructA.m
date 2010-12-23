clear;
clc;
close all;

%% Set Parameters
SampleName = 'R108C60_22_20x_';
resize = 0.5;

%% perform the reconstruction
for whichone=1:1
    tic;
    for FileNumber = 256:256:768
        %% define Names and such
        ProtocolName = ['A'];
        Filename=[SampleName ProtocolName(whichone) '_conc_' ];
        disp(['reconstructing sinogram ' num2str(FileNumber) ' of Protocol ' num2str(ProtocolName(whichone))]);
        %% calculate
        h_Reconstruct(Filename,FileNumber,resize);    
    end
    toc;
    disp( '----------------------------');
    disp(['--- done with protocol ' num2str(ProtocolName(whichone)) ' ---']);
    disp( '----------------------------');
end
disp('Finished with everything you asked me for...');