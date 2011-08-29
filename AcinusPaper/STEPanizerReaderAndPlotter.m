%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reader for
% P:\doc\#Tables\AcinarTreeExtraction\AcinusGrössenVergleichSTEPanizer.xls
% to have a nice plot for the Paper
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all;
close all;

%% Reading XLS-File
XLSFile = 'P:\doc\#Tables\AcinarTreeExtraction\AcinusGrössenVergleichSTEPanizer.xls';
B = xlsread(XLSFile,5);
C = xlsread(XLSFile,6);
D = xlsread(XLSFile,7);
E = xlsread(XLSFile,8);

%% Extracting Data
B=B(:,4:5);
C=C(:,4:5);
D=D(:,4:5);
E=E(:,4:5);
Concatenate = [B',C',D',E']';
size(Concatenate)
Concatenate =Concatenate(isfinite(Concatenate(:,1)),:); % from http://is.gd/ckddR0

%% Present it to the User
Mean = mean(Concatenate);
Sigma = std(Concatenate);
disp(['The mean with all values is ' num2str(Mean(2)) '%.'])
disp(['The standard deviation with all values is ' num2str(Sigma(2)) '%.'])

%% Plot all values and export to TikZ
figure(1)
    plot(1:size(Concatenate,1),Concatenate(:,1),'-bs')
    hold on
    plot(1:size(Concatenate,1),Concatenate(:,2),'-rs')
    matlab2tikz('MeVisLabVsSTEPanizerAllValues.tex')
    title(['All Values: mean ' num2str(Mean(2)) '%'])

%% Remove all values above a certain Threshold
disp('---')
disp('---')
disp('---')
disp('---')
Threshold=130;
Remove=find(Concatenate(:,2)>Threshold); % Find all values bigger than Threshold%
for i=1:size(Remove)
    disp(['Removing (' num2str(Remove(i)) ',' num2str(Concatenate(Remove(i),2)) '), because it is bigger than ' num2str(Threshold)])
end
disp('---')
disp(['In total we counted ' num2str(size(Concatenate,1)) ' acini and removed ' num2str(size(Remove,1)) ' of them.'])
disp(['We thus have ' num2str(size(Concatenate,1)-size(Remove,1)) ' in our measurement.'])
disp('---')
disp('---')
disp('---')
for i = Remove
    Concatenate(i,:)=NaN; % Remove these Values
end
Concatenate = Concatenate(isfinite(Concatenate(:,1)),:); % from http://is.gd/ckddR0

%% Calculate Mean and present again
Mean = mean(Concatenate);
Sigma = std(Concatenate);
disp(['The mean without values (' num2str(Remove') ') is ' num2str(Mean(2)) '%.'])
disp(['The standard deviation with all values (' num2str(Remove') ') is ' num2str(Sigma(2)) '%.'])

figure(2)
	plot(1:size(Concatenate,1),Concatenate(:,1),'-bs')
    hold on
    plot(1:size(Concatenate,1),Concatenate(:,2),'-rs')
    matlab2tikz('MeVisLabVsSTEPanizer.tex')    
    title(['Without Values ' num2str(Remove') ', mean ' num2str(Mean(2)) '%'])
    
