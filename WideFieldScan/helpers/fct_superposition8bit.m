function [superposition] = fct_superposition8bit(detailmask1, detailmask2)
   
    R1(1:size(detailmask1,1),1:size(detailmask1,2)) = 1;
    G1(1:size(detailmask1,1),1:size(detailmask1,2)) = 0;
    B1(1:size(detailmask1,1),1:size(detailmask1,2)) = 0;


    R2(1:size(detailmask2,1),1:size(detailmask2,2)) = 0;
    G2(1:size(detailmask2,1),1:size(detailmask2,2)) = 1;
    B2(1:size(detailmask2,1),1:size(detailmask2,2)) = 0;

    colormask1(:,:,1) = uint8(double(detailmask1).*R1);
    colormask1(:,:,2) = uint8(double(detailmask1).*G1);
    colormask1(:,:,3) = uint8(double(detailmask1).*B1);
    
    colormask2(:,:,1) = uint8(double(detailmask1).*R2);
    colormask2(:,:,2) = uint8(double(detailmask1).*G2);
    colormask2(:,:,3) = uint8(double(detailmask1).*B2);
    
    superposition = imadd(colormask1,colormask2);
    
end