%% definition
%% wfs-compareDMS
%% loads some DMPs from Disk and compares them, to validate wfs-sim

%% 1.12.2008 - initial version, used stuff from mergeprojectionsTIFF.m

%% init
clear;
close all;
clc;
warning off Images:initSize:adjustingMag % suppress the warning about big ...
    % images, they are still displayed correctly, just a bit smaller..
tic; disp(['It`s now ' datestr(now) ]);

% which Protocol?
SamplePrefixName = 'R108C21C';
Suffixes = ['b';'c';'d';'e';'f';'g';'h';'i';'j';'k';'l';'m';'n';'o';'p';'q';'r';'s';'t'];
Suffixes = Suffixes(1:3:end);
SliceNumbers = 1:250:1001;
writeimages = 1;

%% setup
UserID = 'e11126';

if isunix == 1 
    %beamline
    whereamI = '/sls/X02DA/data/';
    %slslc05
    %whereamI = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/';
    PathToFiles = '/Data10/2008c/';    
    BasePath = fullfile( whereamI , UserID , PathToFiles );
    addpath([ whereamI UserID '/MATLAB'])
    addpath([ whereamI UserID '/MATLAB/SRuCT']) 
else
    whereamI = 'E:';
    PathToFiles = '/2008c/';
    BasePath = fullfile(whereamI, PathToFiles);   
    addpath('P:\MATLAB')
    addpath('P:\MATLAB\SRuCT')
end

InputDirectory = 'tif';
OutputDirectory = 'mrg';
ReadDirectory = 'viewrec';

%% load the images

Slice = 4;%1:length(SliceNumbers)

for Protocol = 1:length(Suffixes)
    for FileNumber = Slice
        disp(['loading Protocol ' num2str(Suffixes(Protocol)) ', DMP #' num2str(sprintf('%04d',SliceNumbers(FileNumber))) ]);
        FileName = [ BasePath OutputDirectory filesep SamplePrefixName ...
            Suffixes(Protocol) '_' OutputDirectory filesep ReadDirectory ...
            filesep SamplePrefixName Suffixes(Protocol) '_' OutputDirectory ...
            sprintf('%04d',SliceNumbers(FileNumber)) '.rec.DMP' ];
        TMP = readDumpImage(FileName);
        % cut out middle part
        start = round(size(TMP,1)/3);
        TMP = TMP(start-50:2*start+150,:);
        % resize
        TMP = imresize(TMP,.25);
        % save into one big "image"
        I(:,:,Protocol,FileNumber) = TMP;
        clear TMP;
        if writeimages==1
            imwrite(I(:,:,Protocol,FileNumber),...
                [ BasePath OutputDirectory filesep SamplePrefixName ...
                Suffixes(Protocol) '_' OutputDirectory filesep ReadDirectory ...
                filesep SamplePrefixName Suffixes(Protocol) '_' OutputDirectory ...
                sprintf('%04d',SliceNumbers(FileNumber)) '.tif' ],...
                'Compression','none');
        end
    end
end

% scale grayvalues
I=I-min(min(min(min(I))));
I=I./max(max(max(max(I))));

figure;
	subplotcounter=1;
    for Protocol=1:length(Suffixes)
        for FileNumber=Slice
            subplot(length(Suffixes),length(SliceNumbers),subplotcounter)
            imshow(I(:,:,Protocol,FileNumber),[]);
            title([ num2str(Suffixes(Protocol)) '-' num2str(sprintf('%04d',SliceNumbers(FileNumber))) ]);
        subplotcounter = subplotcounter + 1;
        end
    end
   
% whichProtocol = 1;
% whichSlice = 1;
% figure;
%     hold on
%     for whichSlice = 1:length(SliceNumbers)
%         subplot(1,5,whichSlice)
%             imshow(I(:,:,whichProtocol,whichSlice));
%             title([ num2str(Suffixes(whichProtocol)) '/' num2str(sprintf('%04d',SliceNumbers(whichSlice))) ]);
%     end

    
%% DiffImages
subplotcounter=1;
figure;
for Protocol = 1:length(Suffixes)
    for SliceNumber = 1:length(SliceNumbers);
        DiffImage(:,:,Protocol,SliceNumber) = I(:,:,1,SliceNumber) - I(:,:,Protocol,SliceNumber);
%         figure;
            subplot(length(Suffixes),length(SliceNumbers),subplotcounter)
                imshow(DiffImage(:,:,Protocol,SliceNumber),[]);
                title([ 'DiffImage' num2str(Suffixes(Protocol)) '-' num2str(sprintf('%04d',SliceNumbers(SliceNumber))) ' with A' ]);
        % write out DiffImages
%             filepath = [BasePath OutputDirectory filesep DMPDirectory filesep SamplePrefixName Suffixes(Protocol) '-diffSlice' sprintf('%04d',SliceNumbers(SliceNumber)) 'Diff' num2str(SliceNumber) '.tif']
%             imwrite(DiffImage(:,:,Protocol,SliceNumber),filepath);
        subplotcounter=subplotcounter+1;
    end
end
       
%% finish
disp('I`m done with all you`ve asked for...')
disp(['It`s now ' datestr(now) ]);
zyt=toc;sekunde=round(zyt);minute = floor(sekunde/60);stunde = floor(minute/60);
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
        num2str(round(sekunde)) ' seconds to perform the given task' ]);
end
%helpdlg('I`m done with all you`ve asked for...','Phew!');