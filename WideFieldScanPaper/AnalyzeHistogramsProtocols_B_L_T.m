% we're reading all histograms
% we are building a graph of all histograms

clc
clear all
close all

addpath('P:\MATLAB\matlab2tikz')

ReadPath = 'D:\SLS\2008c\mrg\';

Histograms = dir([fileparts(ReadPath) filesep '*.txt']);
disp(['We have ' num2str(numel(Histograms)) ' .txt-files in the Directory ' ReadPath ]);

MinRows=NaN;
MaxRows=NaN;

for i=1:numel(Histograms)
    Histograms(i).content = importdata([ ReadPath Histograms(i).name ]);
    %Histograms(i).content.data = unique(Histograms(i).content.data, 'rows');
    disp([ 'Histogram(' num2str(i) ') for ' Histograms(i).name ' contains ' num2str(size(Histograms(i).content.data,1)) ' entries/rows.'] );
    MinRows=min(MinRows,size(Histograms(i).content.data,1));
    MaxRows=max(MaxRows,size(Histograms(i).content.data,1));
end

disp([ 'We have a minimal amount of ' num2str(MinRows) ' rows and a maximal amount of ' num2str(MaxRows) ' rows.' ])

figure
for i=1:numel(Histograms)
    subplot(3,4,i)
        plot(Histograms(i).content.data(1:500,1),Histograms(i).content.data(1:500,2))
        title(['Histogram ' num2str(i)])
end

% for i=1:numel(Histograms)
%     disp(['minimum of ' num2str(i) ' is ' num2str(min((Histograms(i).content.data(:,2)))) ]);
% end
% 
% for i=1:numel(Histograms)
%     disp(['maximum of ' num2str(i) ' is ' num2str(max((Histograms(i).content.data(:,2)))) ]);
% end

% figure
% for i=1:numel(Histograms)/3
% 	subplot(3,4,i)
%         semilogy(Histograms(i).content.data(:,2)-Histograms(i+8).content.data(:,2))
%         title(['Histogram-Difference B-L-T ' num2str(i)])
% end

ConcatenatedHistogram(:,1) = Histograms(1).content.data(:,1) /1e6 *1.48e3; % /1e6 because of DTF-scaling, *1e4 because of mm to um scaling of MeVisLab
for i=1:numel(Histograms)
    ConcatenatedHistogram(:,i+1) = Histograms(i).content.data(:,2 );
end

%% Show Plots
scrsz = get(0,'ScreenSize');
AmountOfROIs = 4;
figure('Position',[50 50 scrsz(3)-150 scrsz(4)-150])
for WhichROI = 1:AmountOfROIs
   subplot(2,2,WhichROI)
        semilogy(ConcatenatedHistogram(:,1),ConcatenatedHistogram(:,WhichROI+1:AmountOfROIs:end))
        legend(Histograms(WhichROI:AmountOfROIs:end).name)
%         legend(['B (ROI ' num2str(WhichROI) ')'],...%
%             ['L (ROI ' num2str(WhichROI) ')'],...%
%             ['T (ROI ' num2str(WhichROI) ')'])
        xlabel('Thickness [um]')
        ylabel('Pixel Count')
end

figure('Position',[50 50 scrsz(3)-150 scrsz(4)-150])
for WhichProtocol = 1:3
    %disp(['4*WhichProtocol-3=' num2str(((4*WhichProtocol)-3)+1) ]);
    %disp(['4*WhichProtocol=' num2str(4*WhichProtocol) ]);
    subplot(1,3,WhichProtocol)
        semilogy(ConcatenatedHistogram(:,1),ConcatenatedHistogram(:,(4*WhichProtocol-3)+1:4*WhichProtocol+1))
        legend(Histograms((4*WhichProtocol-4)+1:4*WhichProtocol).name)
%         legend(['ROI 1 Prot. ' num2str(WhichProtocol) ],...%
%             ['ROI 2 Prot. ' num2str(WhichProtocol) ],...%
%             ['ROI 3 Prot. ' num2str(WhichProtocol) ],...%
%             ['ROI 4 Prot. ' num2str(WhichProtocol) ])
end

%% Save Plots with TikZ
for WhichROI = 1:AmountOfROIs
    figure
        semilogy(ConcatenatedHistogram(:,1),ConcatenatedHistogram(:,WhichROI+1:AmountOfROIs:end))
        legend(Histograms(WhichROI:AmountOfROIs:end).name)
        xlabel('Thickness [um]')
        ylabel('Pixel Count')
    FileName = [ ReadPath 'ROI-' num2str(WhichROI) '.tex' ];
    disp(['Saving plot to ' FileName ]);
	matlab2tikz(FileName);
    close;
end

Protocols = ['B','L','T'];
for WhichProtocol = 1:3
    figure
        semilogy(ConcatenatedHistogram(:,1),ConcatenatedHistogram(:,(4*WhichProtocol-3)+1:4*WhichProtocol+1))
        legend(Histograms((4*WhichProtocol-4)+1:4*WhichProtocol).name)
    FileName = [ ReadPath 'Protocol-' Protocols(WhichProtocol) '.tex' ];
    disp(['Saving plot to ' FileName ]);
	matlab2tikz(FileName);
    close;
end

disp('Finished with everything you`ve asked for!')