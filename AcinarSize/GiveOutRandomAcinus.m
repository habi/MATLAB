%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spitting out random acinar number, so I don't have to think
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;clear all;close all;
Total = 33;
HowMany = 10;

disp(['Random selection of ' num2str(HowMany) ' acini from a total of ' num2str(Total) ' Acini to look at.']);

%% Randomily select 'HowMany+5' Acini out of 'Total'
for i = 1:HowMany+5
    Number(i) = round(rand*Total); 
end

%% Discard the ones selected twice
Number=unique(Number);

%% Display
for i = 1:HowMany
    disp(['Look at Acinus Nr. ' num2str(round(rand*Total))]);
end