tic
clear all;close all;clc;
warning off Images:initSize:adjustingMag;

BeamTime = '2008c';
Protocols = [{'b'},{'c'},{'d'},{'e'},{'f'},{'g'},{'h'},{'i'},{'j'},...
    {'k'},{'l'},{'m'},{'n'},{'o'},{'p'},{'q'},{'r'},{'s'},{'t'}];
SamplePrefix = 'R108C21C';
% recFolder = 'rec_8bit';resize2008c=1; % load cropped slices
recFolder = 'original_rec_8bit';resize2008c=0; % load original slices

% BeamTime = '2009a';
% Protocols = [{'a'},{'b'},{'c'},{'d'},{'e'},{'f'},{'g'},{'h'}];
% SamplePrefix = 'R108C36C';
% recFolder = 'rec_8bit';

% BeamTime = '2009b';
% Protocols = [ ...
%     {'A'},{'Aa'},{'Ab'},{'Ac'}, ...
%     {'B'},{'Ba'},{'Bb'},{'Bc'}, ...
%     {'C'},{'Ca'},{'Cb'},{'Cc'}, ...
%     {'D'},{'Da'},{'Db'},{'Dc'}];
% SamplePrefix = 'R108C36B';
% recFolder = 'rec_8bit_';

% BeamTime = '2009c';
% Protocols = [{'A'},{'B'},{'C'},{'D'},{'E'}];
% SamplePrefix = 'R108C60B_t';
% recFolder = 'rec_8bit_';

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
ResizeSize = 500; % "1" = -> don't resize
SlicesFrom = 250;
SlicesStep = 15;
SlicesTo = 1024;

showFigures = 1;
doThreshold = 0;
writeToFiles = 0;

%% read files, threshold them with Otsu and calculate error/similarity
SliceCounter = 1;
SlicesToDo = [SlicesFrom:SlicesStep:SlicesTo];
disp(['Calculating for ' num2str(numel(SlicesToDo)) ' different slices'])
disp('---')
pause(1)

for Slice = SlicesToDo
    close all;
    for ProtocolCounter = 1:size(Protocols,2)
        disp([ 'Working on Slice ' num2str(Slice) ' of Protocol ' num2str(cell2mat(Protocols(ProtocolCounter))) ]);
            if BeamTime == '2008c'
                CurrentSample = [ SamplePrefix num2str(cell2mat(Protocols(ProtocolCounter))) '_mrg' ];
            else
                CurrentSample = [ SamplePrefix '-' num2str(cell2mat(Protocols(ProtocolCounter))) '-mrg' ];
            end
            FileName = [ FilePath filesep CurrentSample filesep recFolder filesep ...
                CurrentSample num2str(sprintf('%04d',Slice)) '.rec.8bit.tif' ];
        disp(['Reading ' FileName]);
            Details(ProtocolCounter).RecTif = imread(FileName);
            if BeamTime == '2008c'
                if resize2008c == 1
                    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                    disp('!!! Sice @ Beamtime 2008c all cropped slices have different size, we`re resizing them to [952 2712] !!');
                    disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
                    Details(ProtocolCounter).RecTif = imresize(Details(ProtocolCounter).RecTif,[952 2712]);
                end
            end
        disp(cell2mat([ 'Slice ' num2str(Slice) ' of Protocol ' Protocols(ProtocolCounter) ...
            ' has a size of ' num2str(size(Details(ProtocolCounter).RecTif,1)) 'x' ...
            num2str(size(Details(ProtocolCounter).RecTif,2)) ' px.' ]));
        if ResizeSize ~= 1
            disp(['Resizing to ' num2str(ResizeSize) ' px for the long side to speed up calculations.']);
                Details(ProtocolCounter).RecTif = imresize(Details(ProtocolCounter).RecTif,[ NaN ResizeSize ]);
            disp(['Image Size is now ' num2str(size(Details(ProtocolCounter).RecTif,1)) ...
                'x' num2str(size(Details(ProtocolCounter).RecTif,2)) ' px.']);
        end
        if doThreshold == 1
            disp('Calculating Otsu Threshold and Thresholding Image...')
                Details(ProtocolCounter).Threshold = graythresh(Details(ProtocolCounter).RecTif);
                Details(ProtocolCounter).ThresholdedSlice = ...
                    im2bw(Details(ProtocolCounter).RecTif,Details(ProtocolCounter).Threshold);
                Details(ProtocolCounter).Threshold = Details(ProtocolCounter).Threshold * ...
                    intmax(class(Details(ProtocolCounter).RecTif)); % save Threshold with 8 or 16 bit into .Threshold
                disp(['Threshold is ' num2str(Details(ProtocolCounter).Threshold) ]);
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
            if doThreshold == 0
                [ Details(ProtocolCounter).SSIM Details(ProtocolCounter).SSIMMap ] = ...
                    ssim_index(Details(1).RecTif,Details(ProtocolCounter).RecTif);
            elseif doThreshold == 1
               [ Details(ProtocolCounter).SSIM Details(ProtocolCounter).SSIMMap ] = ...
                    ssim_index(Details(1).ThresholdedSlice,Details(ProtocolCounter).ThresholdedSlice);
            end
        disp('---')
        ImgError(ProtocolCounter,SliceCounter) = Details(ProtocolCounter).Error;
    	ImgSSIM(ProtocolCounter,SliceCounter) = Details(ProtocolCounter).SSIM;
    end

    if showFigures == 1
        for ProtocolCounter = 1:size(Protocols,2)
            figure
                subplot(221)
                    imshow(Details(ProtocolCounter).RecTif,[]);
                    title(cell2mat([ 'Slice ' num2str(sprintf('%04d',Slice)) ' of Protocol ' Protocols(ProtocolCounter) ]));
                subplot(222)
                    imshow(Details(ProtocolCounter).ThresholdedSlice,[]);
                    if doThreshold == 1
                        title([ 'Thresholded with ' num2str(Details(ProtocolCounter).Threshold * intmax(class(Details(ProtocolCounter).RecTif)))]);
                    elseif doThreshold == 0
                        title('No Thresholding has been done (Original Img)');
                    end
                subplot(223)
                    imshow(Details(ProtocolCounter).DiffImg,[]);
                    title(cell2mat([ 'Difference Image to Protocol ' Protocols(1) ]));
                subplot(224)
                    imshow(max(0,Details(ProtocolCounter).SSIMMap).^4);
                    title(cell2mat([ 'SSIM (A,' Protocols(ProtocolCounter) ')= ' num2str(Details(ProtocolCounter).SSIM) ]));
        end

        figure
        for ProtocolCounter = 1:size(Protocols,2)
            subplot(size(Protocols,2)^.5,size(Protocols,2)^.5,ProtocolCounter);
                imshow(Details(ProtocolCounter).SSIMMap,[]);
                title(cell2mat([ 'SSIM(' Protocols(ProtocolCounter) ')=' num2str(Details(ProtocolCounter).SSIM) ]));
        end
        pause(0.001)
    end

	for ProtocolCounter = 1:size(Protocols,2)
        disp(cell2mat([ 'Threshold(' Protocols(ProtocolCounter) ',' num2str(Slice) ')=' ...
            num2str(Details(ProtocolCounter).Threshold) ]));
    end
	for ProtocolCounter = 1:size(Protocols,2)
        disp(cell2mat([ 'Error(' Protocols(ProtocolCounter) ',' num2str(Slice) ')=' ...
            num2str(Details(ProtocolCounter).Error) ]));
    end
    for ProtocolCounter = 1:size(Protocols,2)
        disp(cell2mat([ 'SSIM(' Protocols(ProtocolCounter) ',' num2str(Slice) ')=' ...
            num2str(Details(ProtocolCounter).SSIM) ]));
    end
    
    disp('---');
    SliceCounter = SliceCounter + 1;
end

FileSuffix = [ 'slices' num2str(sprintf('%04d',SlicesFrom)) '-' ...
    num2str(sprintf('%04d',SlicesStep)) '-' num2str(sprintf('%04d',SlicesTo)) ...
    '-resize' num2str(sprintf('%04d',ResizeSize)) ];
ErrorFileName = [ FilePath filesep 'ImgError-' BeamTime '-' FileSuffix ]; % writing to .xls in both cases, so Excel can open it
SSIMFileName = [ FilePath filesep 'ImgSSIM-' BeamTime '-' FileSuffix ];

if isunix == 1
    ErrorFile = [ ErrorFileName '.csv' ];
    SSIMFile = [ SSIMFileName '.csv' ];
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
    ErrorFile = [ ErrorFileName '.xls' ];
    SSIMFile = [ SSIMFileName '.xls' ];
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
        legend(num2str(SlicesToDo'),'Location','Best') % or 'BestOutside'
%figure
	subplot(222)
        errorplot=mean(ImgError');
        errorstddev=std(ImgError');
        errorbar(errorplot,errorstddev)
        title([ 'mean Error for ' num2str(length(SlicesToDo)) ' Slices \pm Std-Dev' ])
        xlabel('Protocols')
        ylabel('mean \Sigma \Sigma DiffImg')
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
        legend(num2str(SlicesToDo'),'Location','Best') % or 'BestOutside'
%figure       
     subplot(224)
        ssimplot=mean(ImgSSIM,2);
        ssimstddev=std(ImgSSIM,0,2);
        errorbar(ssimplot,ssimstddev);
        title([ 'mean SSIM for ' num2str(length(SlicesToDo)) ' Slices \pm Std-Dev' ])
        xlabel('Protocols')
        ylabel('mean SSIM')
        set(gca,'XTick',[1:length(Protocols)])
        set(gca,'XTickLabel',rot90(fliplr(Protocols)))
        
if BeamTime == '2008c' %Scale the SSIM-Values from 16-116%
    scale = 16:116;
    Quality = max(max(ImgError)) - ImgError;
    Quality = (Quality - min(min(Quality)))* ( (max(scale)-min(scale))/(max(max(Quality))-min(min(Quality))))+ min(scale) % scale from 20:100, so we have the same plot as in the simulation...
    ImgSSIM = (ImgSSIM - min(min(ImgSSIM)))* ( (max(scale)-min(scale))/(max(max(ImgSSIM))-min(min(ImgSSIM))))+ min(scale) % scale from 20:100, so we have the same plot as in the simulation...
end

qualityplot=mean(Quality,2);
qualitystddev=std(Quality,0,2);

ssimplot=mean(ImgSSIM,2);
ssimstddev=std(ImgSSIM,0,2);

if BeamTime == '2008c'
    
    NumberOfProjections = ...
        [ 5244, 5244, 5244;
        5244, 2622, 5244;
        4370, 4370, 4370;
        4370, 2185, 4370;
        3934, 3934, 3934;
        3934, 1967, 3934;
        3496, 3496, 3496;
        3496, 1748, 3496;    
        3060, 3060, 3060;
        3060, 1530, 3060;
        2622, 2622, 2622;
        2622, 1311, 2622;
        2186, 2186, 2186;
        2185, 1093, 2185;
        1748, 1748, 1748;
        1748,  874, 1748;
        1312, 1312, 1312; 
         874,  874,  874;
          874, 437,  874;];
    TotalProjectionsPerProtocol = sum(NumberOfProjections,2)
    [ dummy SortIndex ] = sort(TotalProjectionsPerProtocol);
    
    ScanningTime = TotalProjectionsPerProtocol / max(TotalProjectionsPerProtocol) * 116;
    
    figure % SSIM
        errorbar(ScanningTime(SortIndex),ssimplot(SortIndex),ssimstddev(SortIndex))
        title([ 'mean SSIM for ' num2str(length(SlicesToDo)) ' Slices \pm Std-Dev' ])
        ylabel('mean SSIM(B,*)')
        xlabel(['Time used [Percent of Gold Standard]']);
        %xTicks = [1:numel(Protocols)] ./ numel(Protocols) * ( max(ScanningTime) - min(ScanningTime)) + min(ScanningTime);
        %set(gca,'XTick',xTicks)
        %set(gca,'XTickLabel',rot90(Protocols))
        addpath('P:\MATLAB\matlab2tikz\');
        matlab2tikz([ SSIMFileName '.tex']);
    figure % Quality
        errorbar(ScanningTime(SortIndex),qualityplot(SortIndex),qualitystddev(SortIndex))
        title([ 'mean Quality for ' num2str(length(SlicesToDo)) ' Slices \pm Std-Dev' ])
        ylabel('mean Quality(B,*) [%]')
        xlabel(['Time used [Percent of Gold Standard]']);
        %xTicks = [1:numel(Protocols)] ./ numel(Protocols) * ( max(ScanningTime) - min(ScanningTime)) + min(ScanningTime);
        %set(gca,'XTick',xTicks)
        %set(gca,'XTickLabel',rot90(Protocols))
        addpath('P:\MATLAB\matlab2tikz\');
        matlab2tikz([ ErrorFileName '.tex']);
end

if BeamTime == '2009b'
    figure       
        hold on
        errorbar(ssimplot(1:4:end),ssimstddev(1:4:end),'color','red')
        errorbar(ssimplot(2:4:end),ssimstddev(2:4:end),'color','green')
        errorbar(ssimplot(3:4:end),ssimstddev(3:4:end),'color','blue')
        errorbar(ssimplot(4:4:end),ssimstddev(4:4:end),'color','magenta')
        title([ 'mean SSIM for ' num2str(length(SlicesToDo)) ' Slices \pm Std-Dev' ])
        xlabel('Reduced \# of Projections for central SubScan','Interpreter','none')
        ylabel('mean SSIM(A,*)')
        legend(Protocols(1:4:end))
        set(gca,'XTick',[1:4])
        set(gca,'XTickLabel',['**';'*a';'*c';'*d'])
        addpath('P:\MATLAB\matlab2tikz\');
            disp([ 'Writing plot to ' SSIMFileName '-ABCD.tex']);
            matlab2tikz([ SSIMFileName '-ABCD.tex']);
            print([ SSIMFileName '-ABCD.png'],'-dpng')
        
    figure       
        hold on
        errorbar(ssimplot(1:4),ssimstddev(1:4),'color','red')
        errorbar(ssimplot(5:8),ssimstddev(5:8),'color','green')
        errorbar(ssimplot(9:12),ssimstddev(9:12),'color','blue')
        errorbar(ssimplot(13:end),ssimstddev(13:end),'color','magenta')
        title([ 'mean SSIM for ' num2str(length(SlicesToDo)) ' Slices \pm Std-Dev' ])
        xlabel('Reduced \# of Projections for central SubScan','Interpreter','none')
        ylabel('mean SSIM(A,*)')
        legend(['**';'*a';'*c';'*d'])
        set(gca,'XTick',[1:4])
        set(gca,'XTickLabel',rot90(fliplr(Protocols(1:4:end)))) 
            disp([ 'Writing plot to ' SSIMFileName '-AAaAbAc.tex']);
            matlab2tikz([ SSIMFileName '-AAaAbAc.tex']);
            print([ SSIMFileName '-AAaAbAc.png'],'-dpng')
end

%% [color=red, only marks, mark = * ]
%% [color=green, only marks, mark = diamond*]
%% [color=blue, only marks, mark = square*]
%% [color=magenta, only marks, mark = triangle*]

%Protocols
%ssimplot
%ssimstddev

disp('---');
disp(['Elapsed time is approx. ' num2str(round(toc/60)) ' minutes.']);

disp('Finished with everything you asked for.');
