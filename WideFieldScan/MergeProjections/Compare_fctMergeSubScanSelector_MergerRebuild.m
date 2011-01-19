%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compare Old vs. New
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear;
close all;

Image = 512;
Path = 'r:\SLS';
%Sample = 'R108C04Aa_B1_mrg';
Sample = 'R108C36A_B1_mrg';
%Sample = 'R108C60B_B1_mrg';

Data(1).Folder = 'mrg';

Data(2).Suffix = 'mrgrbld';

Data(1).Name = 'Old'; %Selector
Data(2).Name = 'New'; %MergerRebuild

for i=1:2
    Data(i).FileName = [ Path filesep '2010b' filesep Data(i).Folder filesep Sample ...
        filesep 'rec_8bit_' Data(i).Suffix filesep Sample num2str(sprintf('%04d',Image)) ...
        '.rec.8bit.tif' ];
    disp(['Loading `' Data(i).Name '`: ' Data(i).FileName ])
    Data(i).Slice = imread(Data(i).FileName);
    Data(i).Resize = [];
end

if size(Data(1).Slice) ~= size(Data(2).Slice)
    ResizeSize = [ 512 512 ];
    disp('---')
    disp([ Data(1).Name '-Size (' num2str(size(Data(1).Slice,1)) 'x' ...
        num2str(size(Data(1).Slice,2)) 'px) is not equal to ' ...
        Data(2).Name '-Size (' num2str(size(Data(2).Slice,1)) 'x' ...
        num2str(size(Data(2).Slice,2)) 'px), we are thus resizing both to ' ...
        num2str(ResizeSize(1)) 'x' num2str(ResizeSize(2)) 'px.']);
    for i=1:2
        Data(i).Slice = imresize(Data(i).Slice,[1024 1024]);
    end
    Data(i).Resize = 'Resized ';
    disp('---')
end

figure('name','Projections','Position',[100 200 1500 600])
    for i=1:2
        subplot(1,3,i)
            imshow(Data(i).Slice,[]);
            title([ Data(i).Name '/Slice ' num2str(Image) '/' ...
                num2str(size(Data(i).Slice,1)) 'x' num2str(size(Data(i).Slice,2)) ...
                'px' ],'interpreter','none')
    end
    subplot(133)
        imshow(imabsdiff(Data(1).Slice,Data(2).Slice),[]);
        title([Data(i).Resize 'Difference Image']);