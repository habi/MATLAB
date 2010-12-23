% fill small holes
% from http://blogs.mathworks.com/steve/2008/08/05/filling-small-holes/
clear;
close all;

original = imread('circbw.tif');
figure
subplot(231)
    imshow(original)
    title('original')

filled = imfill(original, 'holes');
subplot(232)
    imshow(filled)
    title('All holes filled')

holes = filled & ~original;
subplot(233)
    imshow(holes)
    title('Hole pixels identified')

bigholes = bwareaopen(holes, 1000);
subplot(234)
    imshow(bigholes)
    title('Only the big holes')
    
smallholes = holes & ~bigholes;
subplot(235)
    imshow(smallholes)
    title('Only the small holes')
    
new = original | smallholes;
subplot(236)
    imshow(new)
    title('Small holes filled')