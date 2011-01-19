%% ZeroPaddingAnalysis
clc;clear all;close all;

Slice = 1024;

ZP00 = imread(['R:\SLS\2010a\mrg\R108C21Bb-mrg\rec_8bit\R108C21Bb-mrg' sprintf('%04d',Slice) '.rec.8bit.tif']);
ZP01 = imread(['R:\SLS\2010a\mrg\R108C21Bb-mrg\rec_8bit_zp01\R108C21Bb-mrg' sprintf('%04d',Slice) '.rec.8bit.tif']);
ZP02 = imread(['R:\SLS\2010a\mrg\R108C21Bb-mrg\rec_8bit_zp02\R108C21Bb-mrg' sprintf('%04d',Slice) '.rec.8bit.tif']);
ZP05 = imread(['R:\SLS\2010a\mrg\R108C21Bb-mrg\rec_8bit_zp05\R108C21Bb-mrg' sprintf('%04d',Slice) '.rec.8bit.tif']);
ZP10 = imread(['R:\SLS\2010a\mrg\R108C21Bb-mrg\rec_8bit_zp10\R108C21Bb-mrg' sprintf('%04d',Slice) '.rec.8bit.tif']);
ZPn05 = imread(['R:\SLS\2010a\mrg\R108C21Bb-mrg\rec_8bit_zpN05\R108C21Bb-mrg' sprintf('%04d',Slice) '.rec.8bit.tif']);
ZPn10 = imread(['R:\SLS\2010a\mrg\R108C21Bb-mrg\rec_8bit_zpN10\R108C21Bb-mrg' sprintf('%04d',Slice) '.rec.8bit.tif']);

slicethickness = 1000;
middle = size(ZP00,1) / 2;

figure
    subplot(171)
        imshow(ZP00(:,middle-slicethickness/2:middle+slicethickness/2),[])
        title('ZeroPadding 0')
    subplot(172)
        imshow(ZP01(:,middle-slicethickness/2:middle+slicethickness/2),[])
        title('ZeroPadding 0.1')
    subplot(173)
        imshow(ZP02(:,middle-slicethickness/2:middle+slicethickness/2),[])
        title('ZeroPadding 0.2')
    subplot(174)
        imshow(ZP05(:,middle-slicethickness/2:middle+slicethickness/2),[])
        title('ZeroPadding 0.5')
    subplot(175)
        imshow(ZP10(:,middle-slicethickness/2:middle+slicethickness/2),[])
        title('ZeroPadding 1.0')
    subplot(176)
        imshow(ZPn05(:,middle-slicethickness/2:middle+slicethickness/2),[])
        title('ZeroPadding -0.5')
    subplot(177)
        imshow(ZPn10(:,middle-slicethickness/2:middle+slicethickness/2),[])
        title('ZeroPadding -1.0')        