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
B_data = xlsread(XLSFile,5);
C_data = xlsread(XLSFile,6);
D_data = xlsread(XLSFile,7);
E_data = xlsread(XLSFile,8);

%% Extracting Data (Relative Volumes)
B = B_data(:,4:5);
C = C_data(:,4:5);
D = D_data(:,4:5);
E = E_data(:,4:5);

B = B(isfinite(B(:,1)),:); % from http://is.gd/ckddR0
C = C(isfinite(C(:,1)),:); % from http://is.gd/ckddR0
D = D(isfinite(D(:,1)),:); % from http://is.gd/ckddR0
E = E(isfinite(E(:,1)),:); % from http://is.gd/ckddR0

B_abs = B_data(:,2:3);
C_abs = C_data(:,2:3);
D_abs = D_data(:,2:3);
E_abs = E_data(:,2:3);

B_abs = B_abs(isfinite(B_abs(:,1)),:); % from http://is.gd/ckddR0
C_abs = C_abs(isfinite(C_abs(:,1)),:); % from http://is.gd/ckddR0
D_abs = D_abs(isfinite(D_abs(:,1)),:); % from http://is.gd/ckddR0
E_abs = E_abs(isfinite(E_abs(:,1)),:); % from http://is.gd/ckddR0

B_abs = B_abs(1:end-1,:);
%deleterow = 1;
%B_abs(deleterow,:)=[];
C_abs = C_abs(1:end-1,:);
D_abs = D_abs(1:end-1,:);
%deleterow = 9;
%D_abs(deleterow,:)=[];
E_abs = E_abs(1:end-1,:);

Concatenate = [B',C',D',E']';
Concatenate_abs = [B_abs',C_abs',D_abs',E_abs']';

figure('Name','Relative Values')
    plot(1:size(B,1),B(:,2),'rs')
    hold on
    axis([ 0 size(Concatenate,1) 0 max((Concatenate(:,2)))])
    from = size(B,1);
    plot(1+from:from+size(C,1),C(:,2),'gs')
    from = from + size(C,1);
    plot(1+from:from+size(D,1),D(:,2),'bs')
    from = from + size(D,1);
    plot(1+from:from+size(E,1),E(:,2),'ks')
    legend(['B (' num2str(size(B,1)) ')'],...
        ['C (' num2str(size(C,1)) ')'],...
        ['D (' num2str(size(D,1)) ')'],...
        ['E (' num2str(size(E,1)) ')'],...
        'Location','SouthEast')
    title('All counted Acini')
    matlab2tikz('MeVisLabVsSTEPanizerStacked.tex')

figure('Name','Absolute Values')
    plot(1:size(B_abs,1),B_abs(:,2),'rs')
    hold on
    axis([ 0 size(Concatenate_abs,1) 0 max((Concatenate_abs(:,2)))])
    from = size(B_abs,1);
    plot(1+from:from+size(C_abs,1),C_abs(:,2),'gs')
    from = from + size(C_abs,1);
    plot(1+from:from+size(D_abs,1),D_abs(:,2),'bs')
    from = from + size(D_abs,1);
    plot(1+from:from+size(E_abs,1),E_abs(:,2),'ks')
    legend(['B_abs (' num2str(size(B_abs,1)) ')'],...
        ['C_abs (' num2str(size(C_abs,1)) ')'],...
        ['D_abs (' num2str(size(D_abs,1)) ')'],...
        ['E_abs (' num2str(size(E_abs,1)) ')'],...
        'Location','SouthEast')
    title('All counted Acini')

Concatenate = Concatenate(isfinite(Concatenate(:,1)),:); % from http://is.gd/ckddR0
Concatenate_abs = Concatenate_abs(isfinite(Concatenate_abs(:,1)),:); % from http://is.gd/ckddR0

%% Present it to the User
Mean_abs = mean(Concatenate_abs);
Sigma_abs = std(Concatenate_abs);
disp(['   We counted ' num2str(size(Concatenate_abs,1)) ' acini.'])
disp('Absolute Values:')
disp(['   Their mean volume is ' num2str(Mean_abs(2)) ' ul.'])
disp(['   The standard deviation of the above value is ' num2str(Sigma_abs(2)) ' ul.'])

Mean = mean(Concatenate);
Sigma = std(Concatenate);
disp('Relative Values:')
disp(['   The mean with all values is ' num2str(Mean(2)) '%.'])
disp(['   The standard deviation with all values is ' num2str(Sigma(2)) '%.'])

%% Plot all values and export to TikZ
figure('Name','All relative Values')
    plot(1:size(Concatenate,1),Concatenate(:,1),'-bs')
    hold on
    plot(1:size(Concatenate,1),Concatenate(:,2),'-rs')
    axis([ 0 size(Concatenate,1) 0 1.1*max((Concatenate(:,2)))])
    matlab2tikz('MeVisLabVsSTEPanizerAllValues.tex')
    title(['All Values: mean ' num2str(Mean(2)) '%'])

%% Remove all values above a certain Threshold
disp('---')
Threshold=130;
Remove=find(Concatenate(:,2)>Threshold); % Find all values bigger than Threshold%
for i=1:size(Remove)
    disp(['Removing (' num2str(Remove(i)) ',' num2str(Concatenate(Remove(i),2)) '), because it is bigger than threshold ' num2str(Threshold)])
end
disp('---')
disp(['In total we counted ' num2str(size(Concatenate,1)) ' acini and removed ' num2str(size(Remove,1)) ' of them.'])
disp(['We thus have ' num2str(size(Concatenate,1)-size(Remove,1)) ' in our measurement.'])
disp('---')
for i = Remove
    Concatenate(i,:)=NaN; % Remove these Values
end
Concatenate = Concatenate(isfinite(Concatenate(:,1)),:); % from http://is.gd/ckddR0

%% Calculate Mean and present again
Mean = mean(Concatenate);
Sigma = std(Concatenate);
disp(['The mean without values above threshold (' num2str(Remove') ') is ' num2str(Mean(2)) '%,'])
disp(['i.e. ' num2str(Mean(2)-Mean(1)) '% bigger.'])
disp(['The standard deviation without the values above is ' num2str(Sigma(2)) '%.'])

figure('Name','Cleaned Relative Values')
	plot(1:size(Concatenate,1),Concatenate(:,1),'-bs')
    hold on
    plot(1:size(Concatenate,1),Concatenate(:,2),'-rs')
    axis([ 0 size(Concatenate,1) 0 1.1*max((Concatenate(:,2)))])
    matlab2tikz('MeVisLabVsSTEPanizerCropped.tex')    
    title(['Without Values ' num2str(Remove') ', mean ' num2str(Mean(2)) '%'])
