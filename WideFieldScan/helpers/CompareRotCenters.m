clc;clear all;close all;

A='C:\Documents and Settings\haberthuer\Desktop\RotCenter\R108C60-b-A-mrg1444-00.DMP';
B='C:\Documents and Settings\haberthuer\Desktop\RotCenter\R108C60-b-A-mrg1444-50.DMP';
C='C:\Documents and Settings\haberthuer\Desktop\RotCenter\R108C60-b-A-mrg1445-00.DMP';
D='C:\Documents and Settings\haberthuer\Desktop\RotCenter\R108C60-b-A-mrg1445-50.DMP';
DiffImg1 = imsubtract(readDumpImage(A),readDumpImage(B));
DiffImg2 = imsubtract(readDumpImage(A),readDumpImage(C));
%DiffImg3 = imsubtract(readDumpImage(A),readDumpImage(D));
DiffImg3 = imsubtract(DiffImg1,DiffImg2);
figure
    imshow(DiffImg1,[]);
    title('A-B')
figure
    imshow(DiffImg2,[]);
    title('A-C')
figure
    imshow(DiffImg3,[]);
    title('A-D')