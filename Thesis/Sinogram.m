clc;clear all;close all

writeout = 1;

for Blob = 1:3
    Slice = imread(['P:\MATLAB\Thesis\Blob' num2str(Blob) '.tif']);
    Theta = 0:179;
    Sin = radon(Slice,Theta)';
    Reconstruction = iradon(Sin',Theta);

    figure('Position',[50 50 1200 800])
        for Row=1:2:size(Sin,1)   
            subplot(241)
                imshow(imrotate(Slice,Row+90,'crop'),[])
                title('Rotating Sample')
                for whichline=((size(Slice,2)/2)-(size(Slice,2)/6)):25:((size(Slice,2)/2)+(size(Slice,2)/6))
                    line(0:size(Slice,2),whichline,'Color','yellow')
                end
             subplot(242)
                imshow(Slice,[])
                [x,y] = pol2cart((Row-90)/180*pi,size(Slice,1)/sqrt(2));
                line([x+size(Slice,1)/2 -x+size(Slice,1)/2],...
                    [y+size(Slice,2)/2 -y+size(Slice,2)/2],...
                    'Color','r')
                title([{'Original Slice with rotating'},...
                    cell2mat({'Projection Plane @ ' ...
                    num2str(sprintf('%03d',Row)) '°'})])
            subplot(243)
                imshow(Sin,[])
                line(0:size(Sin,2),Row,'Color','r','LineStyle','--')
                title([{'Sinogram with'},{'highlighted Row'}])
            subplot(244)
                imshow(Reconstruction,[])
                title('Reconstruction')
            subplot(2,4,5:8)
                plot(Sin(Row,:),'Color','red')
                axis([0 size(Slice,1)*sqrt(2) 0 max(max(Sin))*1.1 ])
                title([ 'Row ' num2str(sprintf('%03d',Row)) ' of ' num2str(size(Sin,1)) ])
            if writeout == 1
                FileName = [ 'C:\Documents and Settings\haberthuer\Desktop\AngularSimulation-Blob' num2str(Blob) 'Angle' num2str(sprintf('%03d',Row)) ];
                print('-dpng',[ FileName '.png']);
%                 matlab2tikz([ FileName '.tex']);
            end
            pause(0.001)
        end
end