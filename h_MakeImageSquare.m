function OutputImage = h_MakeImageSquare(InputImage)
% takes input image and zero-pads it with the necessary rows and colums to 
% make it square afterwards.
% Needed, since the SlabInterpolateFunction only (easily) works with square
% images...

% % %-------------Test-----------
% clc;
% clear;
% close all;
% InputImage = Phantom(256);
% InputImage = radon(InputImage);
% Height = size(InputImage,1);
% Width = size(InputImage,2);
% % %-------------Test-----------

Height = size(InputImage,1);
Width = size(InputImage,2);

WidthPadding = ceil ( ( Height - Width ) / 2 );
HeightPadding = Width + WidthPadding + WidthPadding - Height;

% size(InputImage);
% size(zeros(HeightPadding,WidthPadding+Width+WidthPadding));
% size(zeros(Height,WidthPadding));
% size(InputImage);

OutputImage = [ zeros(HeightPadding,WidthPadding+Width+WidthPadding) ;...
    zeros(Height,WidthPadding) InputImage zeros(Height,WidthPadding) ];

% Output the sizes, if necessary for control
% size(InputImage)
% size(OutputImage)
% InputSize
% OutputSize
% padding
% size(InputImage)
% size(OutputImage)

% % %-------------Test-----------
% figure(1);
% image(InputImage);
% axis image
% figure;
% image(OutputImage);
% axis image
% % %-------------Test-----------

end