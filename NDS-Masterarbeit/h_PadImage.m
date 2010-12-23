function OutputImage = h_PadImage(InputImage, InputSize, OutputSize)
% takes input image and zero-pads it with the necessary rows and colums to 
% match the output-size.
% Needed, since iradon of MATLAB changes size of images.
% Assumes that the Images are squared and works only for even OutputSizes

% %-------------Test-----------
% clc;
% clear;
% close all;
% Img = Phantom(256);
% InputSize = max(size(Img));
% OutputSize = 364;
% InputImage = Img;
% %-------------Test-----------

padding = ( OutputSize - InputSize ) / 2;

size(zeros(padding,OutputSize));
size(zeros(InputSize,padding));
size(InputImage);

OutputImage = [ zeros(padding,OutputSize); ...
                zeros(InputSize,padding) InputImage zeros(InputSize,padding) ; ...
                zeros(padding,OutputSize) ];

% Output the sizes, if necessary for control
% size(InputImage)
% size(OutputImage)
% InputSize
% OutputSize
% padding
% size(InputImage)
% size(OutputImage)

% %-------------Test-----------
% figure;
% imagesc(Img);
% figure;
% imagesc(OutputImage);
% %-------------Test-----------

end