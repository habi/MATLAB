Image = phantom;

InterpolatedImage=fct_InterpolateImageRows(Image,32,0);
 
figure;
    subplot(121)
        imshow(Image,[]);
    subplot(122)
        imshow(InterpolatedImage,[]);