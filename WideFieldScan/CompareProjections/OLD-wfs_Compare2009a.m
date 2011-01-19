clear;close all;clc;
warning off Images:initSize:adjustingMag;

% 2009a
Protocols = ['a','b','c','d','e','f','g','h'];
%Protocols = [ Protocols(1:3) Protocols(5:8) ]
SamplePrefix = 'R108C36C';

if isunix == 1 
    UserID = 'e11126';
    %beamline
    % whereamI = '/sls/X02DA/data/';
    %slslc05
    whereamI = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da';
    PathToFiles = [ UserID filesep 'Data10' filesep '2009a' filesep 'mrg' ];
    addpath([ whereamI UserID '/MATLAB'])
    addpath([ whereamI UserID '/MATLAB/SRuCT']) 
else
    whereamI = 'S:';
    PathToFiles = [ 'SLS' filesep '2009a' filesep 'mrg' ];
    addpath('P:\MATLAB')
    addpath('P:\MATLAB\SRuCT')
end

path = fullfile(whereamI, PathToFiles);
    
%% setup
showSlices = 0;
doThreshold = 0;
showThresholdedSlices = 0;
showHistogram = 0;
showTogether = 0;
showDifferenceImages = 0;
showSingleError = 0;
   
SliceCounter = 1;
CumulativeError= [];
FromToTo = 1:512:1024;

for CurrentSlice = FromToTo;
    clc;
    disp(['processing slice ' num2str(CurrentSlice)])
    disp('---')
    for CurrentProtocol = 1:length(Protocols)
        %% Load Images
        Details(CurrentProtocol).SliceNumber = sprintf('%04d',CurrentSlice); 
        readpath = [ whereamI filesep PathToFiles  ];
        Details(CurrentProtocol).SampleName = [ SamplePrefix '-' Protocols(CurrentProtocol) '-mrg' ] ;
        FileName = [ readpath filesep Details(CurrentProtocol).SampleName filesep 'rec_8bit' filesep Details(CurrentProtocol).SampleName Details(CurrentProtocol).SliceNumber '.rec.8bit.tif' ];
        disp([ 'reading image ' FileName ]);
        Details(CurrentProtocol).Slice = imread(FileName);
        %% Present them if needed
        if showSlices == 1
            figure
                imshow(Details(CurrentProtocol).Slice,[]);
                title([ Details(CurrentProtocol).SampleName ', Slice ' Details(CurrentProtocol).SliceNumber ]);
                axis on;
        end
        %% Threshold Image if needed
        if doThreshold == 1
            Details(CurrentProtocol).RelThreshold = graythresh(Details(CurrentProtocol).Slice);
            % intmax(class(Slice)) is used to scale the relative Threshold calculated
            % above (which goes from 0 to 1) to the maximum of the Image-class
            % (for uint8 = 255), which might change if we're using 16bit
            % images and save it as absolute Threshold...
            Details(CurrentProtocol).AbsThreshold = Details(CurrentProtocol).RelThreshold * intmax(class(Details(CurrentProtocol).Slice));
            if showHistogram ==1 
                figure
                    % generating the Histogram of the current Slice
                    imhist(Details(CurrentProtocol).Slice);
                    hold on;
                    % plotting the calculated Threshold of the current Slice:
                    % intmax(class(Slice)) is used to scale the Threshold calculated
                    % above (which goes from 0 to 1) to the maximum of the Image-class
                    % (for uint8 = 255), which might change if we're using 16bit
                    % images...
                    plot([ Details(CurrentProtocol).AbsThreshold ,Details(CurrentProtocol).AbsThreshold ]...
                        ,[ 0,max(imhist(Details(CurrentProtocol).Slice))],'r');
                    legend('Histogram',[ 'Otsu Threshold (' num2str(Details(CurrentProtocol).AbsThreshold) ')' ])
                    title([ 'Histogram of ' Details(CurrentProtocol).SampleName ', Slice ' Details(CurrentProtocol).SliceNumber ]);
            end % ShowHistogram
                disp([ 'thresholding ' Details(CurrentProtocol).SampleName ', Slice ' ...
                Details(CurrentProtocol).SliceNumber ' with a threshold of ' ...
                num2str(Details(CurrentProtocol).AbsThreshold) ]);
            Details(CurrentProtocol).ThresholdedSlice = im2bw(Details(CurrentProtocol).Slice,Details(CurrentProtocol).RelThreshold);
            if showThresholdedSlices == 1
                figure
                    imshow(Details(CurrentProtocol).ThresholdedSlice,[]);
                    title([ Details(CurrentProtocol).SampleName ', Thresholded Slice ' Details(CurrentProtocol).SliceNumber ', threshold = ' num2str(Details(CurrentProtocol).AbsThreshold) ]);
                    axis on;
            end % showThresholdedSlices
        end % doThreshold
            if showTogether == 1
                figure('Name',Details(CurrentProtocol).SampleName)
                    if doThreshold == 1
                        subplot(2,2,1)
                    end % doThreshold
                        imshow(Details(CurrentProtocol).Slice,[])
                        title([ 'Slice ' Details(CurrentProtocol).SliceNumber ]);
                    if doThreshold == 1                    
                        subplot(2,2,3)
                            imshow(Details(CurrentProtocol).ThresholdedSlice,[])
                            title([ ' Thresholded Slice (level=' num2str(Details(CurrentProtocol).AbsThreshold) ')']);
                         subplot(2,2,[2,4])
                             imhist(Details(CurrentProtocol).Slice);
                         hold on;
                         plot([ Details(CurrentProtocol).AbsThreshold ,Details(CurrentProtocol).AbsThreshold ]...
                             ,[ 0,max(imhist(Details(CurrentProtocol).Slice))],'--r');
                         legend('Histogram',[ 'Threshold (' num2str(Details(CurrentProtocol).AbsThreshold) ')' ])
                         title('Histogram');
    %                      set(gca,'YScale','log')
                    end % doThreshold
            end % ShowTogether
    end

    %% compute DifferenceImage
    disp('---')
    disp('computing difference images')

    %% find smallest Slice of all
    ResizeSize = Inf;
    disp('---')
    disp('looking for smallest image (since not all reconstructions have the same size...)')
    for i=1:length(Protocols)
        ResizeSize = min(ResizeSize,size(Details(i).Slice,1));
    end
    disp('---')
    disp(['To minimize rounding error, we are resizing all images from around '...
        num2str(ResizeSize) 'x' num2str(ResizeSize) 'px. to a size of '...
        num2str(round(ResizeSize / 2)) 'x' num2str(round(ResizeSize / 2)) 'px.' ]);
    ResizeSize = round(ResizeSize / 2);

    w = waitbar(0,[ 'computing difference images for slice ' num2str(CurrentSlice) ]);
    for CurrentProtocol = 1:length(Protocols)
        waitbar(CurrentProtocol/length(Protocols));
        disp([ 'resizing image ' Details(CurrentProtocol).SampleName ' to ' num2str(ResizeSize) 'x' num2str(ResizeSize) ' pixels' ]);
        if doThreshold == 0
            Details(CurrentProtocol).ResizedSlice = imresize(Details(CurrentProtocol).Slice,  [ ResizeSize NaN ] );
        elseif doThreshold == 1
            Details(CurrentProtocol).ResizedSlice = imresize(Details(CurrentProtocol).ThresholdedSlice,  [ ResizeSize NaN ] );
        end
        Details(CurrentProtocol).DifferenceImage = imabsdiff(Details(1).ResizedSlice,Details(CurrentProtocol).ResizedSlice);
        if showDifferenceImages == 1
            figure
                imshow(Details(CurrentProtocol).DifferenceImage)
        end % showDifferenceImages
        Details(CurrentProtocol).AbsoluteError = sum( sum( Details(CurrentProtocol).DifferenceImage ) );      
        Details(CurrentProtocol).ErrorPerPixel = sum( sum( Details(CurrentProtocol).DifferenceImage ) ) ./ size(Details(CurrentProtocol).DifferenceImage,1); 
    end
    close(w);
    
    %% save all the Errors for later
    CumulativeError = [CumulativeError ; Details.AbsoluteError];
    SliceCounter = SliceCounter + 1;
    
    %% plot current Error
    if showSingleError == 1
        figure
            plot([Details.ErrorPerPixel])
            title('Error per Pixel (au) of the Difference Image compared to Protocol "a".')
            set(gca,'XTick',[1:length(Protocols)])
            set(gca,'XTickLabel',rot90(fliplr(Protocols)))        
    end % showSingelError

    clear Details;
    
    % figure
    %     montage([Details.ResizedSlice],'DisplayRange', []);
    %     title(['Used Slices from the ' num2str(length(Protocols)) ' Protocols'])

end %CurrentSlice

for i = 1:size(FromToTo,2)
    NormCumulativeError(i,:) = CumulativeError(i,:) ./ max(CumulativeError(i,:));
end

figure
    subplot(121)
        plot(rot90(CumulativeError,-1))
        title([{'Error per Pixel (au) of the Difference Image '},...
            {['compared to Protocol "a" for ' num2str(SliceCounter-1) ' Slices']}])
        set(gca,'XTick',[1:length(Protocols)])
        set(gca,'XTickLabel',rot90(fliplr(Protocols)))
    subplot(122)
        plot(rot90(NormCumulativeError,-1))
        title([{'Normalized Error per Pixel (au) of the Difference Image'},...
            {['compared to Protocol "a" for ' num2str(SliceCounter-1) ' Slices']}])
        set(gca,'XTick',[1:length(Protocols)])
        set(gca,'XTickLabel',rot90(fliplr(Protocols)))

if isunix == 0
    OutputPath = 'C:\Documents and Settings\haberthuer\Desktop\';
    xlsfile = [ OutputPath '2009a.xls'];
    xlswrite(xlsfile, CumulativeError )
    disp(['Written CumulativeError to ' xlsfile]);
    addpath('P:\MATLAB\matlab2tikz-0.0.1');
end

figure
    plot(rot90(CumulativeError,-1))
    title(['Error per Pixel (au) of the Difference Image compared to Protocol "a" for ' num2str(SliceCounter-1) ' Slices'])
    set(gca,'XTick',[1:length(Protocols)])
    set(gca,'XTickLabel',rot90(fliplr(Protocols)))
if isunix == 0
    cd(OutputPath)
    matlab2tikz('2009aCumulativeError.tex')
end

figure
    plot(rot90(NormCumulativeError,-1))
    title(['Normalized Error per Pixel (au) of the Difference Image compared to Protocol "a" for ' num2str(SliceCounter-1) ' Slices'])
    set(gca,'XTick',[1:length(Protocols)])
    set(gca,'XTickLabel',rot90(fliplr(Protocols)))
if isunix == 0
    matlab2tikz('2009aNormalizedCumulativeError.tex')
end

figure
    errorbar(1:size(Protocols,2),mean(NormCumulativeError),std(NormCumulativeError))
    title(['Mean Normalized Error per Pixel (au) of the Difference Image compared to Protocol "a" for ' num2str(SliceCounter-1) ' Slices'])
    set(gca,'XTick',[1:length(Protocols)])
    set(gca,'XTickLabel',rot90(fliplr(Protocols)))

figure
    plot(mean(NormCumulativeError))
    title(['Mean Normalized Error per Pixel (au) of the Difference Image compared to Protocol "a" for ' num2str(SliceCounter-1) ' Slices'])
    set(gca,'XTick',[1:length(Protocols)])
    set(gca,'XTickLabel',rot90(fliplr(Protocols)))
if isunix == 0
    matlab2tikz('2009aMeanNormalizedCumulativeError.tex')
    close
end

FromToTo
CumulativeError
NormCumulativeError
MeanCumulativeError = mean(NormCumulativeError)
StandardDeviationofCumulativeError = std(NormCumulativeError)

disp('Finished with everything you asked for.');