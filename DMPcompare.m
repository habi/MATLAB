clear;
close all;
clc;

Protocol = ['A','B','C','D','E','F'];
Slice = 1;
which = 'rec2' ;
path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/';
Slice = [ sprintf('%04d',Slice)];

for k=2 %1:length(Protocol)
    file  = [ path 'R108C60_22_20x_' num2str(Protocol(k)) '_conc/'...
              which '/R108C60_22_20x_' num2str(Protocol(k)) '_conc'...
              num2str(Slice) '.rec.DMP'];
    im=readDumpImage(file);
    if k==1
        imA=im;
    elseif k==2
        imB=im;
    elseif k == 3
        imC = im;
    elseif k == 4
        imD = im;
    elseif k == 5
        imE = im;
    elseif k == 6
        imF = im;
    end
    figure(k)
        imagesc(im);
        colormap gray
        axis image 
        title([ num2str(Protocol(k)) ' slice ' Slice ])
    clear im
end
    
diffAB = imA - imB;
diffAC = imA - imC;
diffAD = imA - imD;
diffAE = imA - imE;
diffAF = imA - imF;

figure
    imagesc(diffAB);
    colormap gray
    axis image
    title('A - B')

figure
    imagesc(diffAC);
    colormap gray
    axis image
    title('A - C')
    
figure
    imagesc(diffAD);
    colormap gray
    axis image
    title('A - D')
    
figure
    imagesc(diffAE);
    colormap gray
    axis image
    title('A - E')
    
figure
    imagesc(diffAF);
    colormap gray
    axis image
    title('A - F')
    
disp('Finished with everything you asked for.');