function NumberOfProjections = h_reducesegments(TotalWidth_px,SegmentWidth_px,ImageAtomWidth_px,SegmentNumber,InitialQuality,SegmentQuality)

NumberOfProjections = [];

if SegmentNumber < 1
    disp('segment <1')
    return
end

NumberOfProjections = [ InitialQuality * TotalWidth_px ];
SegmentCounter = 1;

NextTotalWidth_px = TotalWidth_px;
LowestNumber = SegmentWidth_px * SegmentQuality;

while NumberOfProjections(SegmentCounter) >= SegmentWidth_px * SegmentQuality
    if NextTotalWidth_px > NumberOfProjections(SegmentCounter) - SegmentWidth_px
        NextTotalWidth_px = NumberOfProjections(SegmentCounter);
    end
    NumberOfProjections(SegmentCounter+1,1) = NumberOfProjections(SegmentCounter) / 2;
    SegmentCounter = SegmentCounter + 1;
end

if length(NumberOfProjections) > 1
    if abs(NumberOfProjections(SegmentCounter) - LowestNumber) > abs(NumberOfProjections(SegmentCounter-1) - LowestNumber)
        NumberOfProjections = NumberOfProjections(1:length(NumberOfProjections)-1);
    end
%else
%    NumberOfProjections = [];
%    return
end

if SegmentNumber < 2
  return;
end
 
NumberOfSubProjections = h_reducesegments(NextTotalWidth_px,SegmentWidth_px - 2 * ImageAtomWidth_px,ImageAtomWidth_px,SegmentNumber-2,1,SegmentQuality);

NumberOfCenterProjections = NumberOfProjections * ones(1,SegmentNumber-2);

if size(NumberOfSubProjections,1) < 2
    NumberOfProjections = [ NumberOfProjections, NumberOfCenterProjections, NumberOfProjections ];  
    return
else
   NumberOfSubProjections = NumberOfSubProjections(2:size(NumberOfSubProjections,1),:);
end
% SegmentNumber
% NumberOfProjections
% NumberOfSubProjections
% NumberOfCenterProjections
NumberOfProjections = [ [ NumberOfProjections; ones(size(NumberOfSubProjections,1),1)*NumberOfProjections(length(NumberOfProjections)) ], ...
    [ NumberOfCenterProjections;NumberOfSubProjections ], ...
    [ NumberOfProjections; ones(size(NumberOfSubProjections,1),1)*NumberOfProjections(length(NumberOfProjections)) ] ]  ;

end
