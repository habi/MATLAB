clear;
close all;
clc;

path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/';
samplename = 'R108C60_22_20x_';
ProtocolName =   ['A','B','C','D','E','F'];
sins = [1,256,511,512,766,768,1021,1023];
display = 0;
save = 1;
add = '';
%add = '2-rotcorr';
%add = '3-0';
%add = '4-2';
%add = '5-4';

read = 'rec';
write = read;

for whichone = 2:6 %& length(ProtocolName) %1=a 2=b 3=c 4=d 5=e 6=f
    filename = ['R108C60_22_20x_' ProtocolName(whichone) '_conc'];
    for counter = 1:length(sins)
        %% Number to work with
        number = sprintf('%04d',sins(counter));
        %% Inform user
        disp(['converting DMP ' num2str(sins(counter)) ' of protocol '...
            num2str(ProtocolName(whichone)) ' from DMP to ' add ' .tif']);
        %% set filename
        file = [ path filename '/' read add '/' num2str(filename) num2str(number) '.' write '.DMP' ];
        %% read Image with DMP2MATLAB
        img = readDumpImage(file);
        % normalize
        % img = img - min(min(img));
        % img = img / max(max(img));
        %% write
        if save == 1
            imwrite(img,[path filename '/' write add '/' filename number '.' write add '.tif'],'Compression','none');
        end
        %% display if wanted
        if display == 1
            figure;
                colormap 'gray'
                imagesc(img)
                title([filename number '.' write '.tif'])
                axis image
        end
        disp('done');
        clear img
    end
    disp(['finished with ' num2str(ProtocolName(whichone)) '!']);
end
disp('finished with everything you asked for.');
