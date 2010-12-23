clc;

%% Set Parameters
SampleName = 'R108C60_22_20x_';
resize = 0.25;

%% define Names and such
ProtocolName =   [ 'A', 'B', 'C', 'D', 'E', 'F'];
RotCenter =     [ 1534,1534,1534,1534,1534,1534];
sins = [1,256,511,512,766,768,1021,1023];

%% perform the reconstruction
for whichone=2:2
    for namecounter = 1:4
        if namecounter == 1
            name = '';
        elseif namecounter == 2
            name = '2-rotcorr';
        elseif namecounter == 3
             name = '3-0';
        elseif namecounter == 4
            name = '4-2';
        elseif namecounter == 5
            name = '5-4';;
        end
      tic;
        for counter = 2:size(sins,2) % which sinogram should we read?
            %% generate FileNumber for Reconstruction
            FileNumber = sins(counter);
            %% define Filename
            Filename=[SampleName ProtocolName(whichone) '_conc' ];
            %% inform user what's going on
            disp(['reconstructing sinogram ' num2str(FileNumber) ' of protocol '...
                num2str(ProtocolName(whichone)) ', for version ' num2str(name)...
                ' with a Rotation Center of ' num2str(RotCenter(whichone)) ' pixels']);
            %% calculate
            h_Reconstruct(Filename,FileNumber,resize,RotCenter(whichone),name);
            disp('done');
        end
        toc;
        disp( '----------------------------');
        disp(['--- done with version  ' num2str(name) ' ---']);
        disp( '----------------------------');
    end
    disp( '----------------------------');
    disp(['--- done with protocol ' num2str(ProtocolName(whichone)) ' ---']);
    disp( '----------------------------');
end
    
disp('Finished with everything you asked for.');
    