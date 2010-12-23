clear;
clc;
close all;

%% Set Parameters
SampleName = 'R108C60_22_20x_';
ProtocolName = ['A','B','C','D','E','F'];
slices = [1,256,511,512,766,768,1021,1023];
displayslices = 1;
compare = [2 4];
showwhichslice = 6;

tic;

%% set other needed parameters
path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/';

SliceNumberStr = [ sprintf('%04d',slices(showwhichslice)) ];

FileNameFirst = [ path SampleName ProtocolName(compare(1)) ...
    '_conc/rec/' SampleName ProtocolName(compare(1)) '_conc' SliceNumberStr '.rec.tif' ];
FileNameSecond = [ path SampleName ProtocolName(compare(2)) ...
    '_conc/rec/' SampleName ProtocolName(compare(2)) '_conc' SliceNumberStr '.rec.tif' ];

ImageToCompare(:,:,1) = im2double(imread(FileNameFirst));
ImageToCompare(:,:,2) = im2double(imread(FileNameSecond));
ImageToCompare = imresize(ImageToCompare,0.25);

if displayslices == 1
    figure('Name',['Slice ' num2str(slices(showwhichslice)) ' of Protocols '...
        ProtocolName(compare(1)) ' and ' ProtocolName(compare(2))],'NumberTitle','off');;
    colormap gray;
    subplot(121)
        imagesc(ImageToCompare(:,:,1));
        title([ ProtocolName(compare(1)) '/' num2str(slices(showwhichslice)) ]);
        axis image;
    subplot(122)
        imagesc(ImageToCompare(:,:,2));
        title([ ProtocolName(compare(2)) '/' num2str(slices(showwhichslice)) ]);
        axis image;
end
   
% cpselect(ImageToCompare(:,:,1),ImageToCompare(:,:,2));
% mytform = cp2tform(input_points,base_points,'projective');
% registered = imtransform(ImageToCompare(:,:,1),mytform)

%% Perform Registration

% [output registered] = dftregistration(fft2(ImageToCompare(:,:,1)),fft2(ImageToCompare(:,:,2)),100);
% display(output)

[h,matched,theta,I,J]=image_registr_MI(ImageToCompare(:,:,1), ImageToCompare(:,:,2), [-5:.125:5], 0, 0);

figure;
    subplot(1,2,1);
        imagesc(abs(ImageToCompare(:,:,1)));
        title('Reference image');
        axis image;
        colormap gray;
    subplot(1,2,2);
        imagesc(matched);
        title('Registered image');
        axis image;
        

figure;
    subplot(1,2,1);
        imagesc(ImageToCompare(:,:,1)-ImageToCompare(:,:,2));
        title('Ref-2register');
        axis image;
        colormap gray;
    subplot(1,2,2);
        imagesc(ImageToCompare(:,:,1)-matched);
%         imshow(abs(ifft2(registered)));
        title('Ref-registered');
        axis image;
   
savepath = [ path 'comparison/']
mkdir(savepath);
FileNameFirst = [ SampleName ProtocolName(compare(1)) SliceNumberStr '.comp.tif' ]
basename = [ SampleName ProtocolName(compare(1)) 'vs' ProtocolName(compare(2)) ]
imwrite(ImageToCompare(:,:,1),[savepath basename '_original' ...
    ProtocolName(compare(1)) '.comp.tif'],'Compression','none'); 
imwrite(ImageToCompare(:,:,2),[savepath basename '_original' ...
    ProtocolName(compare(2)) '.comp.tif'],'Compression','none'); 
imwrite(matched,[savepath basename '_registered' ProtocolName(compare(2)) ...
    '.comp.tif'],'Compression','none'); 
imwrite(ImageToCompare(:,:,1)-ImageToCompare(:,:,2),[savepath basename ...
    '_orig' ProtocolName(compare(1)) '-orig' ProtocolName(compare(2)) '.comp.tif'],'Compression','none'); 
imwrite(ImageToCompare(:,:,1)-matched,[savepath basename '_orig' ...
    ProtocolName(compare(1)) '-regist' ProtocolName(compare(2)) '.comp.tif'],'Compression','none'); 

toc;

disp('Finished with everything you asked for.');