clc;clear all;close all
% SimulationSize_px = 2000;
MinimalQuality = 16;  % minimal Quality for Simulation
MaximalQuality = 100;  % maximal Quality for Simulation     

% AbsoluteError = [1.2099;1.1950;1.2112;1.2011;1.2220;1.2139;1.2438;1.2369;1.2768;1.2737;1.3298;1.3328;1.4178;1.4311;1.5996;1.6130;1.9708;2.8048;2.7943]*1.0e+005;
% Quality = AbsoluteError;

ErrorPerPixel = [0.0302;0.0298;0.0302;0.0300;0.0305;0.0303;0.0310;0.0309;0.0319;0.0318;0.0332;0.0333;0.0354;0.0357;0.0399;0.0402;0.0492;0.0700;0.0697];
Quality = ErrorPerPixel;

Quality = max(Quality) - Quality;
Quality = Quality ./ max(Quality) * ( MaximalQuality - MinimalQuality) + MinimalQuality;

SortIndex = [19;18;17;16;15;14;12;13;10;11;8;9;6;7;4;5;2;3;1];
TotalProjectionsPerProtocol =[15732;13110;13110;10925;11802; 9835;10488; 8740; 9180; 7650; 7866; 6555; 6558; 5463; 5244; 4370; 3936; 2622; 2185];
ScanningTime = TotalProjectionsPerProtocol / max(TotalProjectionsPerProtocol) * 116;

FitFactor = 4;
figure
  ScanningTime = TotalProjectionsPerProtocol / max(TotalProjectionsPerProtocol) * 116;
  % Calculate fit parameters
  [FittedQuality,ErrorEst] = polyfit(ScanningTime,Quality,FitFactor); % compared to main.m Quality is not transposed!!!
  % Evaluate the fit
  EvalFittedQuality = polyval(FittedQuality,ScanningTime(SortIndex),ErrorEst);
  % Plot the data and the fit
  plot(ScanningTime(SortIndex),EvalFittedQuality,'-',ScanningTime(SortIndex),Quality(SortIndex),'o');
  xlabel('Time used [Percent of Gold Standard]');
  % ylim([0 120]) 
  ylabel('Expected Quality of the Scan [Percent]');
  grid on;
  title('Quality plotted vs. sorted Total Number of Projections');
  legend(['polynomial Fit (' num2str(FitFactor) ')'],'Protocols','Location','SouthEast')
  %legend('polynomial Fit','Protocols','Location','SouthEast')