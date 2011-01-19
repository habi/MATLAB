clc;close all;clear;

I =imread('cameraman.tif');
RelThreshold = graythresh(I)
AbsThreshold = RelThreshold * intmax(class(I))
T = im2bw(I,RelThreshold);

figure;
    subplot(131)
        imshow(I);
        title('Original')
    subplot(132);
        imshow(T);
        title('Thresholded Image')
    subplot(133);
        imhist(I);%,cool);
        hold on;
        plot([ AbsThreshold , AbsThreshold ]...
            ,[ 0 , 10000 ],'.-r');
        legend('Histogram',[ 'Otsu Threshold (' num2str(AbsThreshold) ')' ])
        title([ 'Histogram of rice.png' ]);
[ counts , x ] = imhist(I)        
        
%     hsv        - Hue-saturation-value color map.
%     hot        - Black-red-yellow-white color map.
%     gray       - Linear gray-scale color map.
%     bone       - Gray-scale with tinge of blue color map.
%     copper     - Linear copper-tone color map.
%     pink       - Pastel shades of pink color map.
%     white      - All white color map.
%     flag       - Alternating red, white, blue, and black color map.
%     lines      - Color map with the line colors.
%     colorcube  - Enhanced color-cube color map.
%     vga        - Windows colormap for 16 colors.
%     jet        - Variant of HSV.
%     prism      - Prism color map.
%     cool       - Shades of cyan and magenta color map.
%     autumn     - Shades of red and yellow color map.
%     spring     - Shades of magenta and yellow color map.
%     winter     - Shades of blue and green color map.
%     summer     - Shades of green and yellow color map.
