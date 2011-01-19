function NumberOfProjections = fct_segmentreducer(SampleWidth,AmountOfSubScans,MinimalQuality,MaximalQuality)
    % setup
    disp('assuming that N pixels wide -> N Proj.!');
    NumberOfProjections=[];
    TMPNumberOfProjections=[];
    MinQ = MinimalQuality/100;  %Lowest Simulated Quality
    MaxQ = MaximalQuality/100;  % Highest Simulated Quality
    LeastQ = .3;               % Cutoff Quality > lower generally doesn't make any sense, except the user says it
    PercentageSteps = 0.05;     % Quality-stepping step width
    if LeastQ >= MinQ
        LeastQ = MinQ
        disp(['since you`ve set the minimal quality lower than 0.25, i`ve redefined LeastQ to ' num2str(LeastQ) ])
    end
    % calculate necessary stuff
    SegmentWidth = round (SampleWidth / AmountOfSubScans);
    disp(['SegmentWidth = ' num2str(SegmentWidth) ', Amount of Subscans = ' num2str(AmountOfSubScans)])
    ProtocolCounter = 1;
    CenterScanNumber = ceil( AmountOfSubScans / 2 );
    Qualitysteps = MinQ:PercentageSteps:MaxQ;
    for n=1:length(Qualitysteps)
        disp([ num2str(n) '. Quality-Step: ' num2str(100*Qualitysteps(n)) '%' ]);
    end
    for CurrentQuality = Qualitysteps;
        for n=1:CenterScanNumber %  go from first to central ring-scan
            NumberOfProjections(ProtocolCounter,n)=SampleWidth*CurrentQuality;
        end
        % fill second half with first half
        for n=CenterScanNumber+1:AmountOfSubScans %  go from central ring-scan to the end
            NumberOfProjections(ProtocolCounter,n) = NumberOfProjections(ProtocolCounter,n-CenterScanNumber);
        end
        %pause(1);
        ProtocolCounter = ProtocolCounter + 1;
    end 
    %disp('flipping out!')
    disp(['minimaly requested # of Proj =' num2str(SampleWidth * MinQ) ])
    disp(['minimaly allowed # of Proj =' num2str(SampleWidth * LeastQ) ])
    %disp('unreduced NumProj')
    %NumberOfProjections = flipud(NumberOfProjections)
    %disp('reduced NumProj')        
    AmountOfProtocols = size(NumberOfProjections,1);
    TMPNumberOfProjections = NumberOfProjections;
    for n=1:AmountOfProtocols
        while min(TMPNumberOfProjections(n,CenterScanNumber)/2) >= SampleWidth * LeastQ
            TMPNumberOfProjections(n,CenterScanNumber) = TMPNumberOfProjections(n,CenterScanNumber) / 2;
            TMPNumberOfProjections = [ TMPNumberOfProjections ; TMPNumberOfProjections ];
            NumberOfProjections = [ NumberOfProjections ; TMPNumberOfProjections];
        end
    end
    % only give back unique NumProjs
    NumberOfProjections = flipud(unique(NumberOfProjections,'rows','last'));
    
function OutputRow=fct_rowbisector(InputRow)
    OutputRow = InputRow /2;
end 
  
% NumberOfProjections = [];
% 
% if SegmentNumber < 1
%     disp('segment <1')
%     return
% end
% 
% NumberOfProjections = [ InitialQuality * TotalWidth_px ];
% SegmentCounter = 1;
% 
% NextTotalWidth_px = TotalWidth_px;
% LowestNumber = SegmentWidth_px * SegmentQuality;
% 
% while NumberOfProjections(SegmentCounter) >= SegmentWidth_px * SegmentQuality
%     if NextTotalWidth_px > NumberOfProjections(SegmentCounter) - SegmentWidth_px
%         NextTotalWidth_px = NumberOfProjections(SegmentCounter);
%     end
%     NumberOfProjections(SegmentCounter+1,1) = NumberOfProjections(SegmentCounter) / 2;
%     SegmentCounter = SegmentCounter + 1;
% end
% 
% if length(NumberOfProjections) > 1
%     if abs(NumberOfProjections(SegmentCounter) - LowestNumber) > abs(NumberOfProjections(SegmentCounter-1) - LowestNumber)
%         NumberOfProjections = NumberOfProjections(1:length(NumberOfProjections)-1);
%     end
% %else
% %    NumberOfProjections = [];
% %    return
% end
% 
% if SegmentNumber < 2
%   return;
% end
%  
% NumberOfSubProjections = fct_segmentreducer(NextTotalWidth_px,SegmentWidth_px - 2 * ImageAtomWidth_px,ImageAtomWidth_px,SegmentNumber-2,1,SegmentQuality);
% 
% NumberOfCenterProjections = NumberOfProjections * ones(1,SegmentNumber-2);
% 
% if size(NumberOfSubProjections,1) < 2
%     NumberOfProjections = [ NumberOfProjections, NumberOfCenterProjections, NumberOfProjections ];  
%     return
% else
%    NumberOfSubProjections = NumberOfSubProjections(2:size(NumberOfSubProjections,1),:);
% end
% % SegmentNumber
% % NumberOfProjections
% % NumberOfSubProjections
% % NumberOfCenterProjections
% NumberOfProjections = [ [ NumberOfProjections; ones(size(NumberOfSubProjections,1),1)*NumberOfProjections(length(NumberOfProjections)) ], ...
%     [ NumberOfCenterProjections;NumberOfSubProjections ], ...
%     [ NumberOfProjections; ones(size(NumberOfSubProjections,1),1)*NumberOfProjections(length(NumberOfProjections)) ] ];
end