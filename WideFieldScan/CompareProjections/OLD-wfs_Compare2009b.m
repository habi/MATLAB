clear all;close all;clc;
warning off Images:initSize:adjustingMag;

BeamTime = '2009b';
Protocols = [{'A'},{'B'},{'C'},{'D'},...
            {'Aa'},{'Ba'},{'Ca'},{'Da'},...
            {'Ab'},{'Bb'},{'Cb'},{'Db'},...
            {'Ac'},{'Bc'},{'Cc'},{'Dc'}];
% Protocols = [ Protocols(1:8)]
% Protocols = Protocols(round(16*rand))
SamplePrefix = 'R108C36B';

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
ResizeSize = 2048;
showFigures = 0;
doThreshold = 0;
writeToFiles = 1;

%% read files, threshold them with Otsu and calculate error/similarifty
SliceCounter = 1;
SlicesToDo = [150:5:1024]; % Sample "starts" at Slice 16, we're not starting 'till Slice 50...
for Slice = SlicesToDo
	close all;
    for ProtocolCounter = 1:size(Protocols,2)
        disp([ 'Working on Slice ' num2str(Slice) ' of Protocol ' cell2mat(Protocols(ProtocolCounter)) ]);
            CurrentSample = cell2mat([ SamplePrefix '-' Protocols(ProtocolCounter) '-mrg' ]);
            FileName = [ FilePath filesep CurrentSample filesep 'rec_8bit_' filesep ...
                CurrentSample num2str(sprintf('%04d',Slice)) '.rec.8bit.tif' ];
        disp('Reading...');
            Details(ProtocolCounter).RecTif = imread(FileName);
        disp(cell2mat([ 'Slice ' num2str(Slice) ' of Protocol ' Protocols(ProtocolCounter) ...
            ' has a size of ' num2str(size(Details(ProtocolCounter).RecTif,1)) 'x' ...
            num2str(size(Details(ProtocolCounter).RecTif,2)) ' px.' ]));
        disp(['Resizing to ' num2str(ResizeSize) 'x' num2str(ResizeSize) ' px.']);
            Details(ProtocolCounter).RecTif = imresize(Details(ProtocolCounter).RecTif,[ResizeSize NaN]);
        if doThreshold == 1
            disp('Calculating Otsu Threshold and Thresholding Image...')
                Details(ProtocolCounter).Threshold = graythresh(Details(ProtocolCounter).RecTif);
                Details(ProtocolCounter).ThresholdedSlice = ...
                    im2bw(Details(ProtocolCounter).RecTif,Details(ProtocolCounter).Threshold);
            disp(['Threshold is ' num2str(Details(ProtocolCounter).Threshold ...
                * intmax(class(Details(ProtocolCounter).RecTif))) ]);
        elseif doThreshold == 0
            disp('No Thresholding happens!')
            Details(ProtocolCounter).ThresholdedSlice = Details(ProtocolCounter).RecTif;
            Details(ProtocolCounter).Threshold = NaN;
        end
        disp(cell2mat(['Calculating Difference Image to Protocol ' Protocols(1) ]));
            Details(ProtocolCounter).DiffImg = imabsdiff( ...
                imresize(Details(ProtocolCounter).ThresholdedSlice,[1024 NaN]), ...
                imresize(Details(1).ThresholdedSlice,[1024 NaN]) ...
                );
            Details(ProtocolCounter).DiffImg = imabsdiff(Details(ProtocolCounter).ThresholdedSlice,Details(1).ThresholdedSlice);
        disp('Calculating Sum over the Difference Image')
            Details(ProtocolCounter).Error = sum( sum( Details(ProtocolCounter).DiffImg ) );      
        disp(['Calculating SSIM-Index(A,' cell2mat(Protocols(ProtocolCounter)) ')']) % SSIM-Index implementation from http://is.gd/4XZqM
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
                    title(cell2mat([ 'Slice ' num2str(sprintf('%04d',Slice)) ' of Protocol ' Protocols(ProtocolCounter) ]))
                subplot(222)
                    imshow(Details(ProtocolCounter).ThresholdedSlice,[]);
                    title([ 'Thresholded with ' num2str(Details(ProtocolCounter).Threshold * intmax(class(Details(ProtocolCounter).RecTif)))])
                subplot(223)
                    imshow(Details(ProtocolCounter).DiffImg,[]);
                    title(cell2mat([ 'Difference Image to Protocol ' Protocols(1) ]))
                subplot(224)
                    imshow(max(0,Details(ProtocolCounter).SSIMMap).^4);
                    title([ 'SSIM (A,' Protocols(ProtocolCounter) ')= ' num2str(Details(ProtocolCounter).SSIM) ])
        end

        figure
        for ProtocolCounter = 1:size(Protocols,2)
            subplot(size(Protocols,2)^.5,size(Protocols,2)^.5,ProtocolCounter)
                imshow(Details(ProtocolCounter).SSIMMap,[]);
                title(cell2mat([ 'SSIM(' Protocols(ProtocolCounter) ')=' num2str(Details(ProtocolCounter).SSIM) ]))
        end
    else
    end

    for ProtocolCounter = 1:size(Protocols,2)
        disp(cell2mat([ 'SSIM(' Protocols(ProtocolCounter) ',' num2str(Slice) ')=' ...
            num2str(Details(ProtocolCounter).SSIM) ]));
    end
    
    disp('---');
    SliceCounter = SliceCounter + 1;
end

if writeToFiles == 1
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
end

figure
    subplot(221)
        plot(ImgError)
        title([ 'ImgError for ' num2str(length(SlicesToDo-1)) ' Slices'])% (First Slice is empty, thus omitted).' ])
        xlabel('Protocols')
        ylabel('\Sigma \Sigma DiffImg')
        set(gca,'XTick',[1:length(Protocols)])
        set(gca,'XTickLabel',rot90(fliplr(Protocols)))
        legend(num2str(SlicesToDo'),'Location','BestOutside')
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
        legend(num2str(SlicesToDo'),'Location','BestOutside')
%figure       
     subplot(224)
        ssimplot=mean(ImgSSIM,2); % calculate average of ImgSSIM for plotting it correctly
        ssimstddev=std(ImgSSIM,0,2);
        errorbar(ssimplot,ssimstddev);
        title([ 'mean SSIM for ' num2str(length(SlicesToDo)) ' Slices \pm Std-Dev' ])
        xlabel('Protocols')
        ylabel('SSIM')
        set(gca,'XTick',[1:length(Protocols)])
        set(gca,'XTickLabel',rot90(fliplr(Protocols)))
        
figure       
	ssimplot=mean(ImgSSIM,2);
    ssimstddev=std(ImgSSIM,0,2);
    plot(1:4,ssimplot(1:4),...
        1:4,ssimplot(5:8),...
        1:4,ssimplot(9:12),...
        1:4,ssimplot(13:16));
    title([ 'mean SSIM for ' num2str(length(SlicesToDo)) ' Slices \pm Std-Dev' ])
    xlabel('Protocols')
    ylabel('SSIM')
    legend(Protocols(1:4))
    set(gca,'XTick',[1:4])
    set(gca,'XTickLabel',rot90(fliplr(Protocols(1:4))))
        
Protocols
ssimplot
ssimstddev

disp('---');    
disp('Finished with everything you asked for.');