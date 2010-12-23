clc;clear all;close all;

Path = 'C:\Documents and Settings\haberthuer\Desktop';
Path = 'C:\Users\haberthuer\Desktop';

subplotrows = 4;

%% DICOM
FileName = 'Test.dcm';
disp(['Reading ' Path filesep FileName]);
disp('---');
R = dicomread([Path filesep FileName]);

%% TIF
%FileName = 'Test.tif';
%disp(['Reading ' Path filesep FileName])
% h = waitbar(0,['Reading ' num2str(slices) ' slices']);
% for slice=1:slices;
%     waitbar(slice/slices);
%     % disp(['reading slice ' num2str(slice) '/' num2str(slices) ])
% 	I(:,:,slice) = dicomread([Path filesep FileName],slice);
% end
% close(h)

% level = graythresh(R(:,:,:,1:end));
% R = im2bw(R,level);

%% VIEW
slices = size(R,4);
figure
    for ctr=1:(subplotrows^2)
    subplot(subplotrows,subplotrows,ctr)
        showslice = round(slices/(subplotrows^2)*ctr);
        imshow(R(:,:,showslice)',[]);
        title(['Slice ' num2str(showslice)])
    end

%% SEGMENTED VOLUME
original_voxelsize = 1.48*1e-4;
node_height = 2;
binning = 2^node_height;
R=R/max(max(max(R))); % normalize to 1, if we are working with binarized inputslices
num_voxels = sum(sum(sum(R)));
binned_voxelsize = ( original_voxelsize ) * binning;
totalVolume = size(R,1)*size(R,2)*size(R,4);
disp(['The total volume of the cube is ' num2str(totalVolume) ' pixels (' ...
    num2str(size(R,1)) 'x' num2str(size(R,2)) 'x' num2str(size(R,4)) ')' ])
disp(['The binarized segment in ' FileName ' contains ' num2str(num_voxels) ...
    ' voxels à ' num2str(binned_voxelsize*1e4) ' um sidelength'])
segmented_volume = num_voxels * (binned_voxelsize^3); % micrometers^3 = microliters
disp(['The segment in ' FileName ' thus contains ' num2str(segmented_volume) ' ml in Volume'])

figure
    imshow(1-(sum(R,4)/768));
    title('Summed Slices');
    
tmp(ceil(size(R,1)/10),ceil(size(R,2)/10),ceil(size(R,4)/10))=NaN;
tmp(:,:,:)=R(1:10:end,1:10:end,1:10:end);

break

figure
    fv = isosurface(tmp,1);   

%% ISOSURFACE
figure;
[x,y,z,v] = flow;
p = patch(isosurface(x,y,z,v,-3));
isonormals(x,y,z,v,p)
set(p,'FaceColor','red','EdgeColor','none');
daspect([1 1 1])
view(3); axis tight
camlight 
lighting gouraud