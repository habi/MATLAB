clear;
close all
clc;


whichProtocol = 2;
whichSlice    = 11;

Protocols = ['b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t'];
for whichProtocol = 1:length(Protocols)
    Slices = 1:50:1024;
    Slice = [ sprintf('%04d',Slices(whichSlice))];
    SamplePrefix = 'R108C21C';
    path = '/sls/X02DA/Data10/e11126/2008c/mrg/';
    readDir = 'viewrec';suffix = 'rec';Slice = [ sprintf('%04d',751)];
    %readDir = 'sin';suffix = readDir;Slice = [ sprintf('%04d',Slices(whichSlice))];
    addpath = 'P:\MATLAB\SRuCT';
    imwrite = 0;
    choose = 0;

    if choose == 0
       file = [ path SamplePrefix Protocols(whichProtocol) '_mrg' filesep ...
           readDir filesep SamplePrefix Protocols(whichProtocol) '_mrg' ...
           Slice '.' suffix '.DMP' ];
       Filename = [ SamplePrefix Protocols(whichProtocol) '_mrg' Slice '.' suffix '.DMP' ];
    else
        [Filename,Pathname] = uigetfile('*.DMP','Select a DMP-file to view');
        file = [Pathname Filename];
    end

    %for k=2 %1:length(Protocol)
     %   file  = [ path 'R108C60_22_20x_' num2str(Protocol(k)) '_conc/'...
      %            which '/R108C60_22_20x_' num2str(Protocol(k)) '_conc'...
       %           num2str(Slice) '.rec.DMP'];

    % displayDumpImage(file)   
    image = readDumpImage(file);

    figure
        imshow(image,[]);
        colormap gray
        axis on image
        title(Filename,'Interpreter','none')

    disp([ Filename ' has a size of ' num2str(size(image,1)) 'x' num2str(size(image,2)) ' pixels.']);

    image = image - min(min(image));
    image = image ./ max(max(image));

    if imwrite ==1
        imwrite(image,[file '.tif'])
    end

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
disp('Finished with everything you asked for.');
