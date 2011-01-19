function NumberOfProjections = fct_GenerateSegments(TotalNumOfImages,AmountOfSubScans,MinimumNumOfImages)
  NumberOfProjections = [];
  if ( TotalNumOfImages < MinimumNumOfImages ) || ( AmountOfSubScans < 1 ) || ( round(TotalNumOfImages) ~= TotalNumOfImages )
    return 
  end
  if AmountOfSubScans == 1
    NumberOfProjections = [ TotalNumOfImages ];
    return
  end
  NumberOfProjections(1,:) = [ ones(1,AmountOfSubScans) * TotalNumOfImages ];
  ActualNumOfImages = TotalNumOfImages / 2;
  while 1
    NumberOfSubProjections = fct_GenerateSegments( ActualNumOfImages ,AmountOfSubScans - 2 ,MinimumNumOfImages );
    if isempty(NumberOfSubProjections)
      return
    end
    OuterNumImages = ones(size(NumberOfSubProjections,1),1) * TotalNumOfImages;
    NumberOfProjections = unique( [ ...
                                    NumberOfProjections ; ...
                                    OuterNumImages NumberOfSubProjections OuterNumImages ...
                                  ] , 'rows' );
    ActualNumOfImages = ActualNumOfImages / 2;
  end
end


