function NumberOfProjections = fct_ProtocolGenerator(SampleWidth_px,AmountOfSubScans,MinimalQuality,MaximalQuality,QualityStepWidth)
%% test
% clc;clear all;close all;
% SampleWidth_px=3714;
% DetectorWidth=1024;
% Overlap=100;
% MaximalQuality=100;
% MinimalQuality=20;
% QualityStepWidth = 10;
% AmountOfSubScans=ceil(SampleWidth_px/(DetectorWidth-Overlap));
%% test
    % calculating base NumberOfProjections 
    % BaseNumProj = [ ones(1,AmountOfSubScans)*round(SampleWidth_px * pi / 2) ];
    disp('-----');
    disp(['I am calculating the Number of Projections for ' num2str(AmountOfSubScans) ' SubScans ' ...
        'and for the Quality Range ' num2str(MinimalQuality) '-' num2str(MaximalQuality) '% in steps of ' num2str(QualityStepWidth) '%.']);
    LeastQuality = 30;    % Cutoff Quality > lower generally doesn't make any sense, except the user says it
    if LeastQuality >= MinimalQuality
        disp(['Since you`ve explicitly set the minimal quality lower than ' ...
            num2str(LeastQuality) '%, i`ve redefined the lowest allowed']);
        disp(['Quality to ' num2str(MinimalQuality) '% instead of the normally ' ...
            'used ' num2str(LeastQuality) '%.'])
        LeastQuality = MinimalQuality;
    end
    Qualities = (MaximalQuality:-QualityStepWidth:MinimalQuality)/100;
    MinimumNumberOfImages = floor( SampleWidth_px * MinimalQuality * 0.01 );
    if MinimumNumberOfImages < 3 
      MinimumNumberOfImages = 3
    end
    NumberOfProjections = [];
    for variations = 1:length(Qualities)
      NumberOfProjections = unique( [ ...
                                      NumberOfProjections;
                                      fct_GenerateSegments( round( pi/ 2 * SampleWidth_px * Qualities(variations)) ,AmountOfSubScans ,MinimumNumberOfImages) ...
                                    ],'rows');
    end
    NumberOfProjections = flipud(NumberOfProjections);
end