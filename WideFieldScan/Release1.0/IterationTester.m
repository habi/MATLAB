clc
clear all
close all

% [
% ]
% ;
% :
%  =

Iteration(1) = 1;
Iteration(2) = 2;
Iteration(3) = 1;

AmountOfSubScans = 3;

Projections(1) = 20;
Projections(2) = 10;
Projections(3) = 20;

NumDarks = 1;
NumFlats = 2;

%SubScan.Numbers=NaN

for i=1:AmountOfSubScans
    disp(['Working on SubScan s' num2str(i) ]);
    %pause(1)
	% Pre-Projection
	%for k=1:NumDarks + NumFlats
    %    DestinationFile = num2str((AmountOfSubScans*k)-(AmountOfSubScans-i))
	%end
    % Post-Projection
	for k=1:NumDarks+NumFlats+Projections(i)+NumFlats
        if k <= NumDarks+NumFlats
            Counter = k;
        elseif ( k>NumDarks+NumFlats & k<=NumDarks+NumFlats+Projections(i) )
            Counter = NumDarks + NumFlats + ( ( k - NumDarks- NumFlats ) * Iteration(i) ) ;
        else
            Counter = k + ((Iteration(i)-1)*Projections(i));
        end
        SubScan(i).Numbers(k) = (AmountOfSubScans*Counter)-(AmountOfSubScans-i);
    end
end
    
for i=1:AmountOfSubScans
    SubScan(i).Numbers
end
    
%     disp(['Resorting Post-Flats for SubScan ' num2str(i) ])
%     ResortBar = waitbar(0,['Resorting ' num2str(Data(i).NumFlats) ' Post-Flats of SubScan s' num2str(i)],'name','Please Wait...');
%     for k=Data(i).ProjectionNumberLast:Data(i).ProjectionNumberLast + Data(i).NumFlats
%         OriginalFile = [Data(i).SampleFolder filesep 'tif' filesep Data(i).SubScanName num2str(sprintf('%04d',k)) '.tif' ];
%         DestinationFile = [ OutputDirectory filesep OutPutTifDirName filesep MergedScanName num2str(sprintf(Decimal,(AmountOfSubScans*k)-(AmountOfSubScans-i))) '.tif' ];
%         ResortCommand = [ do ' ' OriginalFile ' ' DestinationFile ];
%         waitbar(k/(Data(i).NumFlats));
%         % disp(ResortCommand);
%         [status,result] = system(ResortCommand);
%     end % k=End of Projections to End of Files
%     close(ResortBar)
%     %% Resort Projections
%     disp(['Resortign Projections for SubScan ' num2str(i) ]);
%         ResortBar = waitbar(0,['Resorting ' num2str(Data(i).ProjectionNumberLast) ' Projections of SubScan s' num2str(i)],'name','Please Wait...');
%     for k=Data(i).ProjectionNumberFirst:Data(i).ProjectionNumberLast
%         OriginalFile = [Data(i).SampleFolder filesep 'tif' filesep Data(i).SubScanName num2str(sprintf('%04d',k)) '.tif' ];
%         DestinationFile = [ OutputDirectory filesep OutPutTifDirName filesep MergedScanName num2str(sprintf(Decimal,((AmountOfSubScans*k)-(AmountOfSubScans-i)))) '.tif' ]; % NUmber outputfile according to Interpolation.
%         ResortCommand = [ do ' ' OriginalFile ' ' DestinationFile ];
%         waitbar(k/(Data(i).ProjectionNumberLast));
%         % disp(ResortCommand);
%         [status,result] = system(ResortCommand);        
%     end % k=Start:End of Projections
%     close(ResortBar)
%

