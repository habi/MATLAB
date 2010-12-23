clear;
close all;
clc;

path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/';
Slice = 1;
Slice = [ sprintf('%04d',Slice)];
showslices = 1;

%% Setup the Protocol-Parameters in a Structure
Compare(1) = struct('Name', 'A', 'appendix' , ''          , 'tick' , 'a'         , 'recIm' , [] , 'diffIm' , [], 'quaderror', 0 ,'errora' , 0 ) ;
Compare(2) = struct('Name', 'B', 'appendix' , ''          , 'tick' , 'b'         , 'recIm' , [] , 'diffIm' , [], 'quaderror', 0 ,'errora' , 0 ) ;
Compare(3) = struct('Name', 'B', 'appendix' , '3-0'       , 'tick' , 'b-0'       , 'recIm' , [] , 'diffIm' , [], 'quaderror', 0 ,'errora' , 0 ) ;
Compare(4) = struct('Name', 'B', 'appendix' , '4-2'       , 'tick' , 'b-2'       , 'recIm' , [] , 'diffIm' , [], 'quaderror', 0 ,'errora' , 0 ) ;
Compare(5) = struct('Name', 'B', 'appendix' , '5-4'       , 'tick' , 'b-4'       , 'recIm' , [] , 'diffIm' , [], 'quaderror', 0 ,'errora' , 0 ) ;
% Compare(6) = struct('Name', 'B', 'appendix' , '2-rotcorr' , 'tick' , 'b-rotcorr' , 'recIm' , [] , 'diffIm' , [], 'quaderror', 0 ,'errora' , 0 ) ;

for counter = 1:length(Compare)
    disp(['working on ' Compare(counter).Name ', case `' Compare(counter).appendix '`.']);
    %load image
    SampleName = [ 'R108C60_22_20x_' Compare(counter).Name '_conc' ];
    file = [ path SampleName '/rec' Compare(counter).appendix '/' SampleName Slice '.rec.DMP' ];
    Compare(counter).recIm = readDumpImage(file);
    if max(size(Compare(counter))) < 3072  
           Compare(counter).recIm = imresize(Compare(counter).recIm,[3072 3072]);
    end
    imsize = size(Compare(counter).recIm)
    if showslices ==1
        figure
            imagesc(Compare(counter).recIm)
            axis image
            colormap gray
            colorbar
%             title(Compare(:).tick);
    end
    % compute Error
    Compare(counter).diffIm = ( Compare(1).recIm - Compare(counter).recIm );
    if showslices ==1
        figure
            imagesc(Compare(counter).diffIm)
            axis image
            colormap gray
            colorbar
    end
    Compare(counter).quaderror = sum ( sum ( Compare(counter).diffIm .^2 ));
    disp(['sum(sum(diffIm .^2)) (with respect to A) is ' num2str(Compare(counter).quaderror) '.' ]);
    disp(['done with ' Compare(counter).Name ', case `' Compare(counter).appendix '`.']);
    disp(['']); 
    disp(['---']); 
    disp(['']); 
end

%% Display Error Plot
figure();
    plot(1:length(Compare),[Compare(:).quaderror],'-xr');
    xlabel('Concatenation')
    ylabel('Error compared to A')
    set(gca,'XTick',[1:length(Compare)])
    set(gca,'XTickLabel',{Compare(:).tick})
%     w=legend('Error to Phantom','Location','NorthWest');

disp('Finished with everything you asked for.');