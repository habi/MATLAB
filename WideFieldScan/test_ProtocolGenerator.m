clc;clear all;close all;

SampleWidth=17000;
DetectorWidth=1024;
Overlap=150;
MaximalQuality=100;
MinimalQuality=1;
StepWidth = 10;

NumberOfProjections = fct_ProtocolGenerator(SampleWidth,...
    ceil(SampleWidth/(DetectorWidth-Overlap)),MinimalQuality,...
    MaximalQuality,StepWidth)
  
AmountOfProtocols=size(NumberOfProjections,1)
AmountOfSubScans=size(NumberOfProjections,2)

TotalSubScans = sum(NumberOfProjections,2);
[dummy sortindex] = sort(TotalSubScans);

%% output
plot(TotalSubScans(sortindex),'--o');
xlabel('Protocol')
ylabel('Total NumProj')
set(gca,'XTick',[1:AmountOfProtocols])
set(gca,'XTickLabel',sortindex)

disp('been there, done that!')
