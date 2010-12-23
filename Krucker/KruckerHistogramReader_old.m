break
clear all
figure

%% Sample 90
HistogramDir = 'd:\SLS\2010b\M251-090S7_';
disp([ 'counting .txt-Files in ' HistogramDir ]);         
HistogramList = dir([ HistogramDir filesep '*.txt']);
disp([ 'We found ' num2str(length(HistogramList)) '.txt-Files in ' HistogramDir ]);         

for i=1:length(HistogramList)
    Histogram(i) = importdata([ HistogramDir filesep HistogramList(i).name ], ' ',1);
    subplot(141)
        plot(Histogram(i).data(:,1),Histogram(i).data(:,2))
        hold on
        title('102')
        XLIM([0 0.07])
        YLIM([0 11e4])
end


%% Sample 102
HistogramDir = 'd:\SLS\2010b\M251-102V7_';
disp([ 'counting .txt-Files in ' HistogramDir ]);         
HistogramList = dir([ HistogramDir filesep '*.txt']);
disp([ 'We found ' num2str(length(HistogramList)) '.txt-Files in ' HistogramDir ]);

for i=1:length(HistogramList)
    Histogram(i) = importdata([ HistogramDir filesep HistogramList(i).name ], ' ',1);
    subplot(142)
        plot(Histogram(i).data(:,1),Histogram(i).data(:,2))
        hold on
        title('102')
        XLIM([0 0.07])
        YLIM([0 11e4])
end

%% Sample 115
HistogramDir = 'd:\SLS\2010b\M251-115O7_';
disp([ 'counting .txt-Files in ' HistogramDir ]);         
HistogramList = dir([ HistogramDir filesep '*.txt']);
disp([ 'We found ' num2str(length(HistogramList)) '.txt-Files in ' HistogramDir ]);         

for i=1:length(HistogramList)
    Histogram(i) = importdata([ HistogramDir filesep HistogramList(i).name ], ' ',1);
    subplot(143)
        plot(Histogram(i).data(:,1),Histogram(i).data(:,2))
        hold on
        title('115')
        XLIM([0 0.07])
        YLIM([0 11e4])
end

%% Sample N01
HistogramDir = 'd:\SLS\2010b\M251-N01_';
disp([ 'counting .txt-Files in ' HistogramDir ]);         
HistogramList = dir([ HistogramDir filesep '*.txt']);
disp([ 'We found ' num2str(length(HistogramList)) '.txt-Files in ' HistogramDir ]);         

for i=1:length(HistogramList)
    Histogram(i) = importdata([ HistogramDir filesep HistogramList(i).name ], ' ',1);
    subplot(144)
        plot(Histogram(i).data(:,1),Histogram(i).data(:,2))
        hold on
        title('N01')
        XLIM([0 0.07])
        YLIM([0 11e4])
end

matlab2tikz('kruckerold.tex')