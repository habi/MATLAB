clear all;close all;clc;
warning off Images:initSize:adjustingMag;

BeamTime = '2009c';
Protocols = ['A','B','C','D','E'];
%Protocols = [ Protocols(1:3) Protocols(5:8) ]
SamplePrefix = 'R108C60B_t';

if isunix == 1 
    UserID = 'e11126';
    %beamline
        % whereamI = '/sls/X02DA/data/';
    %slslc05
        whereamI = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/';
        PathToFiles = [ UserID filesep 'Data10' filesep BeamTime filesep 'mrg' ];
        addpath([ whereamI UserID '/MATLAB'])
        addpath([ whereamI UserID '/MATLAB/SRuCT']) 
else
    whereamI = 'S:';
    PathToFiles = [ 'SLS' filesep BeamTime filesep 'mrg' ];
    addpath('P:\MATLAB')
    addpath('P:\MATLAB\SRuCT')
end

FilePath = fullfile(whereamI, PathToFiles);
    
%% setup
ResizeSize = 1024;
showFigures = 0;

%% read files, threshold them with Otsu and calculate error/similarity
SliceCounter = 1;
SlicesToDo = [101:400:1024]; % Sample "starts" at Slice 16, we're not starting 'till Slice 50...
for Slice = SlicesToDo
    for ProtocolCounter = 1:size(Protocols,2)
        disp([ 'Working on Slice ' num2str(Slice) ' of Protocol ' Protocols(ProtocolCounter) ]);
            CurrentSample = [ SamplePrefix '-' Protocols(ProtocolCounter) '-mrg' ];
            FileName = [ FilePath filesep CurrentSample filesep 'rec_8bit_' filesep ...
                CurrentSample num2str(sprintf('%04d',Slice)) '.rec.8bit.tif' ];
        disp('Reading...');
            Details(ProtocolCounter).RecTif = imread(FileName);
        disp([ 'Slice ' num2str(Slice) ' of Protocol ' Protocols(ProtocolCounter) ...
            ' has a size of ' num2str(size(Details(ProtocolCounter).RecTif,1)) 'x' ...
            num2str(size(Details(ProtocolCounter).RecTif,2)) ' px.' ]);
        disp(['Resizing to ' num2str(ResizeSize) 'px. for the shortest side']);
            Details(ProtocolCounter).RecTif = imresize(Details(ProtocolCounter).RecTif,[ResizeSize NaN]);
        disp('Calculating Otsu Threshold and Thresholding Image...')
            Details(ProtocolCounter).Threshold = graythresh(Details(ProtocolCounter).RecTif);
            Details(ProtocolCounter).ThresholdedSlice = ...
                im2bw(Details(ProtocolCounter).RecTif,Details(ProtocolCounter).Threshold);
        disp(['Threshold is ' num2str(Details(ProtocolCounter).Threshold ...
            * intmax(class(Details(ProtocolCounter).RecTif))) ]);
        disp([ 'Calculating Difference Image to Protocol ' Protocols(1) ])
            Details(ProtocolCounter).DiffImg = imabsdiff( ...
                imresize(Details(ProtocolCounter).ThresholdedSlice,[1024 NaN]), ...
                imresize(Details(1).ThresholdedSlice,[1024 NaN]) ...
                );
            Details(ProtocolCounter).DiffImg = imabsdiff(Details(ProtocolCounter).ThresholdedSlice,Details(1).ThresholdedSlice);
        disp('Calculating the Sum over the Difference Image as an Error-Measure')
            Details(ProtocolCounter).Error = sum( sum( Details(ProtocolCounter).DiffImg ) );      
        disp('Calculating SSIM-Index')
            [ Details(ProtocolCounter).SSIM Details(ProtocolCounter).SSIMMap ] = ...
                ssim_index(Details(1).RecTif,Details(ProtocolCounter).RecTif);
        disp('---')
        ImgError(ProtocolCounter,SliceCounter) = Details(ProtocolCounter).Error;
    	ImgSSIM(ProtocolCounter,SliceCounter) = Details(ProtocolCounter).SSIM;
    end

    if showFigures == 1
        for ProtocolCounter = 1:size(Protocols,2)
            figure
                subplot(221)
                    imshow(Details(ProtocolCounter).RecTif,[]);
                    title([ 'Slice ' num2str(sprintf('%04d',Slice)) ' of Protocol ' Protocols(ProtocolCounter) ])
                subplot(222)
                    imshow(Details(ProtocolCounter).ThresholdedSlice,[]);
                    title([ 'Thresholded with ' num2str(Details(ProtocolCounter).Threshold * intmax(class(Details(ProtocolCounter).RecTif)))])
                subplot(223)
                    imshow(Details(ProtocolCounter).DiffImg,[]);
                    title([ 'Difference Image to Protocol ' Protocols(1) ])
                subplot(224)
                    imshow(Details(ProtocolCounter).SSIMMap,[]);
                    title([ 'SSIM = ' num2str(Details(ProtocolCounter).SSIM) ])
        end

        figure
        for ProtocolCounter = 1:size(Protocols,2)
            subplot(1,size(Protocols,2),ProtocolCounter)
                imshow(Details(ProtocolCounter).SSIMMap,[]);
                title([ 'SSIM(' Protocols(ProtocolCounter) ')=' num2str(Details(ProtocolCounter).SSIM) ])
        end
    else
    end

    for ProtocolCounter = 1:size(Protocols,2)
        disp([ 'SSIM(' Protocols(ProtocolCounter) ',' num2str(Slice) ')=' ...
            num2str(Details(ProtocolCounter).SSIM) ]);
    end
    
    disp('---');
    close all;
    SliceCounter = SliceCounter + 1;
end

ErrorFile = [ FilePath filesep 'ImgError-' BeamTime '.xls']; % writing to .xls in both cases, so Excel can open it
SSIMFile = [ FilePath filesep 'ImgSSIM-' BeamTime '.xls'];

if isunix == 1
    % since 'xlswrite' does not work on Unix, we're resorting to a "hack",
    % cobble together the matrix and write it as comma-separated values,
    % which Excel can open...
    disp([ 'Writing ImgError to ' ErrorFile ])
    ExportTable(1)=NaN;
    ExportTable(1,2:length(SlicesToDo)+1)=SlicesToDo;
	ExportTable(2:size(ImgError,1)+1,2:size(ImgError,2)+1)=ImgError;
    ExportTable(2:1+length(Protocols),1)=Protocols';
    dlmwrite(ErrorFile,ExportTable);
	dlmwrite(ErrorFile,'---','delimiter','','-append')
    dlmwrite(ErrorFile,...
        'The values in the First Row correspond to the ASCII-values of the ProtocolName.',...
        'delimiter','','-append')
    dlmwrite(ErrorFile,'65=A,66=B,67=C,etc.','delimiter','','-append')
    
    disp([ 'Writing ImgSSIM to ' SSIMFile ])
    ExportTable(1)=NaN;
    ExportTable(1,2:length(SlicesToDo)+1)=SlicesToDo;
	ExportTable(2:size(ImgSSIM,1)+1,2:size(ImgSSIM,2)+1)=ImgSSIM;
    ExportTable(2:1+length(Protocols),1)=Protocols';
    dlmwrite(SSIMFile,ExportTable);
	dlmwrite(SSIMFile,'---','delimiter','','-append')
    dlmwrite(SSIMFile,...
        'The values in the First Row correspond to the ASCII-values of the ProtocolName.',...
        'delimiter','','-append')
    dlmwrite(SSIMFile,'65=A,66=B,67=C,etc.','delimiter','','-append')
else
    % xlswrite idea from http://is.gd/xqTc
    disp([ 'Writing ImgError to ' ErrorFile ])
    xlswrite(ErrorFile, {'Slices'},'Sheet1','B1');
    xlswrite(ErrorFile, {'Protocols'},'Sheet1','A2');
    xlswrite(ErrorFile, [SlicesToDo],'Sheet1','B2');
    xlswrite(ErrorFile, num2cell(ImgError),'Sheet1','B3');
    xlswrite(ErrorFile, [Protocols]','Sheet1','A3');

    disp([ 'Writing ImgSSIM to ' SSIMFile ])
    xlswrite(SSIMFile, {'Slices'},'Sheet1','B1');
    xlswrite(SSIMFile, {'Protocols'},'Sheet1','A2');
    xlswrite(SSIMFile, [SlicesToDo],'Sheet1','B2');
    xlswrite(SSIMFile, num2cell(ImgSSIM),'Sheet1','B3');
    xlswrite(SSIMFile, [Protocols]','Sheet1','A3');
end

figure
    subplot(221)
        plot(ImgError)
        title([ 'ImgError for ' num2str(length(SlicesToDo-1)) ' Slices'])% (First Slice is empty, thus omitted).' ])
        xlabel('Protocols')
        ylabel('\Sigma \Sigma DiffImg')
        set(gca,'XTick',[1:length(Protocols)])
        set(gca,'XTickLabel',rot90(fliplr(Protocols)))
%figure
	subplot(222)
        errorplot=mean(ImgError,2);
        errorstddev=std(ImgError,0,2);
        errorbar(errorplot,errorstddev)
        title([ 'mean SSIM for ' num2str(length(SlicesToDo)) ' Slices \pm Std-Dev' ])
        xlabel('Protocols')
        ylabel('SSIM')
        set(gca,'XTick',[1:length(Protocols)])
        set(gca,'XTickLabel',rot90(fliplr(Protocols)))   
%figure
    subplot(223)
        plot(ImgSSIM)
        title([ 'SSIM for ' num2str(length(SlicesToDo)) ' Slices' ])
        xlabel('Protocols')
        ylabel('SSIM')
        set(gca,'XTick',[1:length(Protocols)])
        set(gca,'XTickLabel',rot90(fliplr(Protocols)))
%figure       
     subplot(224)
        ssimplot=mean(ImgSSIM,2);
        ssimstddev=std(ImgSSIM,0,2);
        errorbar(ssimplot,ssimstddev);
        title([ 'mean SSIM for ' num2str(length(SlicesToDo)) ' Slices \pm Std-Dev' ])
        xlabel('Protocols')
        ylabel('SSIM')
        set(gca,'XTick',[1:length(Protocols)])
        set(gca,'XTickLabel',rot90(fliplr(Protocols)))   

disp('---');    
disp('Finished with everything you asked for.');