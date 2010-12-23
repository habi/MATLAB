% we're reading all histograms
% we are building a graph of all histograms

clc
clear all
close all

ReadPath = 'D:\SLS\Mariani\TM4\';

DirectoryListing = dir(fileparts(ReadPath));

disp(['We have ' num2str(numel(DirectoryListing)) ' entries in the Directory ' ReadPath ]);
disp(['Including the `.` and `..`-entry, we have ' num2str(numel(DirectoryListing)-2) ' directories to scan for .txt-files']);
disp('---')

MinContent = NaN;
MaxContent = NaN;

% Generate Filenames to Load
for i=3:numel(DirectoryListing)
    Histograms(i-2).name = DirectoryListing(i).name;
end

for i=1:numel(Histograms)
	Histograms(i).Directory = DirectoryListing(i+2).name;
    Histograms(i).File = dir([ReadPath Histograms(i).name filesep '*.txt']);
    disp(['reading Histogram' Histograms(i).File.name ]);
	Histograms(i).content = importdata([ReadPath Histograms(i).Directory filesep Histograms(i).File.name]);%, ' ', 1);
    disp([ 'Histogram(' num2str(i) ') for ' Histograms(i).name ' contains ' num2str(size(Histograms(i).content.data,1)) ' rows.'] );
    MinContent=min(MinContent,size(Histograms(i).content.data,1));
    MaxContent=max(MaxContent,size(Histograms(i).content.data,1));  
end

disp('---')
disp([ 'The shortest Histogram contains ' num2str(MinContent) ' rows.']);
disp([ 'The longest Histogram contains ' num2str(MaxContent) ' rows.']);

ChooseMinContent = 1;

if ChooseMinContent == 1
    ConcatenatedHistograms(1:MinContent,1:numel(Histograms)-2) = 0;
	x_axis = 0:0.001:(MinContent-1)*0.001;
	disp(['You chose to plot only the ' num2str(MinContent) ' entries from all Histograms'])
    for i=1:numel(Histograms)
        ConcatenatedHistograms(1:MinContent,i)=Histograms(i).content.data(1:MinContent,2);
    end
elseif ChooseMinContent == 0
    ConcatenatedHistograms(1:MaxContent,1:numel(Histograms)-2) = 0;
    x_axis = 0:0.001:(MaxContent-1)*0.001;
	disp(['You chose to plot all ' num2str(MaxContent) ' entries from all Histograms'])
    for i=1:numel(Histograms)
        ConcatenatedHistograms(1:size(Histograms(i).content.data,1),i)=Histograms(i).content.data(:,2);
    end
end

disp(['We have ' num2str(size(ConcatenatedHistograms,1)) ' rows and ' num2str(size(ConcatenatedHistograms,2)) ' colums in the Histograms-Table, which we plot now...'])

figure
    plot(x_axis,ConcatenatedHistograms)
    legend(Histograms(1:numel(Histograms)).name)
    title('Concatenated Histograms')

figure
    semilogy(x_axis,ConcatenatedHistograms)
    legend(Histograms(3:end).name)
	title('Concatenated Histograms (Log-plot for y-Axis)') 
    
% for i=3:numel(Histograms)
%     figure
%         plot(Histograms(i).content.data(1:MinContent,2))
%         title( [ Histograms(i).name '.txt (1:' num2str(MinContent) ') of ' num2str(size(Histograms(i).content.data,1)) ])
%         legend(Histograms(i).name)
% end
