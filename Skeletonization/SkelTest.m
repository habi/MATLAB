%% Description
%% - first version
%% - edited:

%% reset workspace, start timer
clear;close all;clc;disp(['It`s now ' datestr(now) ]);tic;
warning off Images:initSize:adjustingMag;

%% setup
showslices = 0;
SampleName = 'R108C21Cb_mrg';
FileSuffix = '.rec.8bit.tif';

Path = 'S:\SLS\2008c\mrg' ;
ReadSuffix = 'rec_8bit';
WriteSuffix = 'SkeletonizedSlices';

ReadPath = [ Path filesep SampleName filesep ReadSuffix ];
WritePath = [ Path filesep SampleName filesep WriteSuffix ];
[ message status ] = mkdir(WritePath);

ResizeSize = 1;
% xshift = 0;
% yshift = 0;
% PartX = xshift + 1:2792 - xshift;
% PartY = ( 2792/2) - yshift:(2792/2) + yshift;

for SliceNumber = 600:1024
    Details(SliceNumber).ReadName = [ SampleName num2str(sprintf('%04d',SliceNumber)) FileSuffix ];
    %% Read Slice and resize it
    disp([ 'Reading Slice ' Details(SliceNumber).ReadName ]);
    Details(SliceNumber).Slice = imread([ ReadPath filesep Details(SliceNumber).ReadName ]);
%     Slice = Slice(PartY,PartX);
    if ResizeSize ~= 1
        disp(['Resizing to ' num2str(ResizeSize) ' px for the horizontal size.'])
        Details(SliceNumber).Slice = imresize(Details(SliceNumber).Slice,[ResizeSize NaN]);
    end

    %% Threshold Slice
    Details(SliceNumber).Threshold = graythresh(Details(SliceNumber).Slice);
    Details(SliceNumber).ThresholdedSlice = im2bw(Details(SliceNumber).Slice,Details(SliceNumber).Threshold);

    %% Fill Thresholded Slice
    Details(SliceNumber).Clean = bwmorph(Details(SliceNumber).ThresholdedSlice,'clean');
    Details(SliceNumber).Fill = bwmorph(Details(SliceNumber).Clean,'close');

    %% Skeletonize it
    Details(SliceNumber).Skel = bwmorph(Details(SliceNumber).Fill,'skel',Inf);

    if showslices == 1
        figure;
            subplot(221)
                imshow(Details(SliceNumber).Slice,[]);
                title([ 'Original Slice Nr. ' num2str(SliceNumber) ])
            subplot(222)
                imshow(Details(SliceNumber).ThresholdedSlice)
                title(['Thresholded with Threshold ' num2str(Details(SliceNumber).Threshold * intmax(class(Details(SliceNumber).Slice))) ]);
            subplot(223)
                imshow(Details(SliceNumber).Fill)
                title('Filled thresholded Slice');
            subplot(224)
                imshow(Details(SliceNumber).Skel)
                title('Skeletonized Slice');
                truesize

        LineNr = round(size(Details(SliceNumber).Slice,1) / 2);
        figure;
            subplot(211)
                plot(Details(SliceNumber).Slice(LineNr,:))
                title([ 'Plot of central row (' num2str(LineNr) ') of Original Slice ']);
            subplot(212)
                plot(Details(SliceNumber).Skel(LineNr,:))
                title([ 'Plot of central row (' num2str(LineNr) ') of Skeletonized Slice ']);
    end

    % Writing out Skeletonizations
    
	Details(SliceNumber).WriteSkelName = [ SampleName num2str(sprintf('%04d',SliceNumber)) '.skel' FileSuffix ];
    imwrite(Details(SliceNumber).Skel,...
        [ WritePath filesep Details(SliceNumber).WriteSkelName ],'Compression','none');            
    clear Details
    close all
end

% MinThreshold = 1;
% MaxThreshold = 0;
% for SliceNumber = 1:1024/ResizeSize:1024
%     MinThreshold = min(MinThreshold,Details(SliceNumber).Threshold);
%     MaxThreshold = max(MaxThreshold,Details(SliceNumber).Threshold);
% end
% Threshold = ( MinThreshold + MaxThreshold ) / 2;
% 
% counter=1;
% for SliceNumber = 1:1024/ResizeSize:1024
% 	Volume(:,:,counter)= Details(SliceNumber).Slice;
%     Thresholded(:,:,counter)= Details(SliceNumber).ThresholdedSlice;
%     Skeleton(:,:,counter)= Details(SliceNumber).Skel;
%     counter=counter+1;
% end
% 
% figure;
%     Volume = squeeze(Volume);
%     p1 = patch(isosurface(Volume, Threshold),'FaceColor','red','EdgeColor','none');
%     view(3); axis tight;
%     % colormap(gray(100))
%     camlight left; camlight; lighting gouraud
%     isonormals(Skeleton,p1)
%     title('Volume 3D')
% 
% figure;
%     Thresholded = squeeze(Thresholded);
%     p1 = patch(isosurface(Thresholded, .99),'FaceColor','green','EdgeColor','none');
%     view(3); axis tight;
%     % colormap(gray(100))
%     camlight left; camlight; lighting gouraud
%     isonormals(Thresholded,p1)
%     title('Thresholded Slices 3D')
%     
% figure;
%     Skeleton = squeeze(Skeleton);
%     p1 = patch(isosurface(Skeleton, .99),'FaceColor','blue','EdgeColor','none');
%     view(3); axis tight;
%     % colormap(gray(100))
%     camlight left; camlight; lighting gouraud
%     isonormals(Skeleton,p1)
%     title('Skeleton 3D')

%% finish
disp('I`m done with all you`ve asked for...');disp(['It`s now ' datestr(now) ]);
zyt=toc;sekunde=round(zyt);minute = round(sekunde/60);stunde = round(minute/60);
if stunde >= 1
    minute = minute - 60*stunde;
    sekunde = sekunde - 60*minute - 3600*stunde;
    disp(['It took me approx ' num2str(round(stunde)) ' hours, ' ...
        num2str(round(minute)) ' minutes and ' num2str(round(sekunde)) ...
        ' seconds to perform the given task' ]);
else
    minute = minute - 60*stunde;
    sekunde = sekunde - 60*minute;
    disp(['It took me approx ' num2str(round(minute)) ' minutes and ' ...
        num2str(round(sekunde)) ' seconds to perform given task' ]);
end
% helpdlg('I`m done with all you`ve asked for...','Phew!');