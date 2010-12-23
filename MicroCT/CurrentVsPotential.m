% Visualization of different Controlfile setups of the MicroCT at the DKF.
% We aim to plot current [kV] vs. potential [uA] of the x-ray tube.
clc;clear all;close all

Current = [45,45,55,55,70,70];
Potential = [88,177,72,145,57,114];

figure  
    plot(Current(1:2:end),Potential(1:2:end),'r-*');
    hold on
    plot(Current(2:2:end),Potential(2:2:end),'r-*');
    title('Current vs. Potential')
    xlabel('Strom/kV')
    xlim([40 75]) 
    ylabel('Spannung/\mu A')
    ylim([50 190])       

print(['c:\Users\haberthuer\Desktop\CurrentVsPotential.png'],'-dpng')

for equalizeHistogram = 0:1;	% perform Histogram equalization of read images
    for classic = 0:1;          % do classic (1) or adaptive (0) equalization
        
        %% Load Sample R108C21AeROL
        for i=1:6
            disp(['Reading R108C21AeROL, configuration ' num2str(i)])
            if equalizeHistogram == 1 % Do we want to equalize the Histogram?
                if classic == 1
                    Im(:,:,i) = imadjust(imread(['r:\MicroCT\00000035\0000010' num2str(3+i) '\111.tif']));
                    Method = 'Normalized Histogram';
                    Suffix = 'nH';
                    disp('normalizing Histogram...')
                else
                    Im(:,:,i) = adapthisteq(imread(['r:\MicroCT\00000035\0000010' num2str(3+i) '\111.tif']));
                    Method = 'Contrast-limited adaptive histogram equalization';
                    Suffix = 'clahe';
                    disp('adaptive Histogram normalization...')
                end
            else
                Im(:,:,i) = imread(['r:\MicroCT\00000035\0000010' num2str(3+i) '\111.tif']);
                Method = [];
                Suffix = [];
            end
        end
        disp('---')
        
        crop=650;
        figure('Name',['R108C21AeROL ' Method])
            for i=1:6
                subplot(2,6,i)
                    imshow(Im(crop:end-crop,crop:end-crop,i),[])
                    title([ num2str(Current(i)) 'kV/' num2str(Potential(i)) 'A'])
                subplot(2,6,i+6)
                    imhist(Im(crop:end-crop,crop:end-crop,i))
            end

        print(['c:\Users\haberthuer\Desktop\R108C21AeROL' Suffix '.png'],'-dpng')

        %% Load Sample R108C60AeROL
        for i=1:6
            disp(['Reading R108C60AeROL, configuration ' num2str(i)])
            if equalizeHistogram == 1 % Do we want to equalize the Histogram?
                if classic == 1
                    Im(:,:,i) = imadjust(imread(['r:\MicroCT\00000036\0000011' num2str(i-1) '\111.tif']));
                    Method = 'Normalized Histogram';
                    Suffix = 'nH';
                    disp('normalizing Histogram...')
                else
                    Im(:,:,i) = adapthisteq(imread(['r:\MicroCT\00000036\0000011' num2str(i-1) '\111.tif']));
                    Method = 'Contrast-limited adaptive histogram equalization';
                    Suffix = 'clahe';
                    disp('adaptive Histogram normalization...')
                end
            else
                Im(:,:,i) = imread(['r:\MicroCT\00000036\0000011' num2str(i-1) '\111.tif']);
                Method = [];
                Suffix = [];
            end
        end
        disp('---')

        crop=350;
        figure
            for i=1:6
                subplot(2,6,i)
                    imshow(Im(crop:end-crop,crop:end-crop,i),[])
                    title([ num2str(Current(i)) 'kV/' num2str(Potential(i)) 'A'])
                subplot(2,6,i+6)
                    imhist(Im(crop:end-crop,crop:end-crop,i))
            end

        print(['c:\Users\haberthuer\Desktop\R108C60AeROL' Suffix '.png'],'-dpng')
    end
end