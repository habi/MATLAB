clc,clear all,close all

Dark = double(imread('/sls/X02DA/data/e11126/Data10/2010a/R108C04Bb_s1/tif/R108C04Bb_s10001.tif'));
Flat = double(imread('/sls/X02DA/data/e11126/Data10/2010a/R108C04Bb_s1/tif/R108C04Bb_s10010.tif'));

Projection1 = double(imread('/sls/X02DA/data/e11126/Data10/2010a/R108C04Bb_s1/tif/R108C04Bb_s10512.tif'));
Projection2 = double(imread('/sls/X02DA/data/e11126/Data10/2010a/R108C04Bb_s2/tif/R108C04Bb_s20512.tif'));

Flat = Flat - Dark;
 
CorrProjection1 = ( Projection1 - Dark ) ./ Flat;
CorrProjection2 = ( Projection2 - Dark ) ./ Flat;

figure
    subplot(321)
        imshow(Dark,[])
    subplot(322)
        imshow(Flat,[])
    subplot(323)
        imshow(Projection1,[])
    subplot(324)
        imshow(Projection2,[])
    subplot(325)
        imshow(CorrProjection1,[])
    subplot(326)
        imshow(CorrProjection2,[])       

        
overlapold = function_cutline(CorrProjection1,CorrProjection2)
overlapnew = find_overlap(CorrProjection1,CorrProjection2,128,2)