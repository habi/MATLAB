function Output = h_HowManyRings(InputImageMaxWidth,DetectorWidth)
% depending in the diagonal length of the image we need to obtain a varying
% amount of slabs (overlayed images) to cover the full FOV. since only the
% middle of the sample is imaged with 180, we need an odd amount of rings
% to obtain. This function makes this little calculation and ouputs a
% vector [AmountOfRings AmountOfSlabs]

% % ------TEST------
% clc;
% clear;
% close all;
% InputImageMaxWidth = 128;
% DetectorWidth = 23;
% % ------TEST------

RealSlabs = InputImageMaxWidth / DetectorWidth;
Slabs = ceil(RealSlabs);
Rings = floor ( Slabs / 2 );
Output = [Rings Slabs];

% ------TEST------
disp(['The Image-Diagonal is ' num2str(InputImageMaxWidth) ' px wide.'])
disp(['The Detector-Width is set to ' num2str(DetectorWidth) ' px.'])
disp(['We thus need ' num2str(Slabs) ' (' num2str(RealSlabs) ') slabs to cover the full image from left to right.'])
disp(['So we image the core and ' num2str(Rings) ' Ring(s) around it to `see` the full FOV.'])
% ------TEST------

end
