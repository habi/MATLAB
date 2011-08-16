function TotalTime=fct_HowLongDoesItTake(ExposureTime,Projections)

% Since we need to know the total time it takes for a scan, and the time is
% depending on the AmountOfProjections (hence the rotation steps) of the
% single subscans, I've written this function to calculate the time for
% each scan.
% The function expects the ExposureTime and the Projections as input, the
% projections must come in the format like [NumProj;NumProj;NumProj]. From
% this, the function calculates the AmountOfSubScans and outputs the
% TotalTime (in MINUTES!)

% According to Fede (Tel. with her on 25.03.2009) the new stepping
% technique uses the same Camera FiFo, but then sends a hardware trigger to
% the RotationStage. A wait for 200 ms is implemented inbetween. The stage
% rotates with a speed of 90degree/sec.
% We always scan with 180degree-configuration, thus the time taken for 1
% Projection can be assumed to be "1/90 * 180degree * 1/NumProj"

%% 

%% Calculations to extract the total time

% disp(['The exposure time is set to: ' num2str(ExposureTime) ' ms.']);
% disp(['We have ' num2str(size(Projections,1)) ' SubScans.']);

for i=1:size(Projections,2)
    CameraReadOutTime = 451; % according to Fede, the camera has 451 ms readout
    AnglePerProjection = 180 / Projections(i);  
    TimePerProjection = AnglePerProjection * 1 / 90 * 1000; %1s/90degree * 1000 ms/s
    TriggerTime = 200;
    TimePerProjection(i) = ExposureTime + TimePerProjection + TriggerTime;
    if TimePerProjection(i) <= CameraReadOutTime
        disp([' Time per Projection is smaller than Camera Readout Time, ' ...
            ' so I am using the Readout Time.']);
        TimePerProjection(i) = CameraReadOutTime;
    end
    Time(i) = TimePerProjection(i) * Projections(i);
    Time(i) = round(Time(i) / 1000 / 60);
%     disp(['SubScan ' num2str(i) ' with ' num2str(Projections(i)) ...
%          ' Projections will take approx. ' num2str(Time(i)) ' minutes']);
end

TotalTime = sum(Time);
% disp(['Scanning will take approx. ' num2str(TotalTime) ' minutes.']);
TotalTime = TotalTime + size(Projections,2) - 1;
disp('If we account 1 minute for each change between the SubScans,');
disp([ ' then the whole scan will take approx. ' num2str(TotalTime) ' minutes.'] );

end