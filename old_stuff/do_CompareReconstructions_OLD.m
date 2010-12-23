clear;
clc;
close all;

%% Set Parameters
SampleName = 'R108C60_22_20x_';
ProtocolName = ['A','B','C','D','E','F'];
sins = [1,256,511,512,766,768,1021,1023];
showimg = 1;
printimg = 1; %only works if showimg = 1...
writediffimages = 1;
showwhichimg = 256;
normalize = 0;
normalizeoriginals = 0;

%% set other needed parameters
path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/';

for whichone = 1:6 % which protocol
    Protocols(whichone)=whichone;
    tic;
    disp([ '-working on Protocol ' ProtocolName(whichone) '-']);
    ctr = 1:8;
    for counter=ctr % which sinogram/slice? using ctr to we can reuse it below...
        SinogramNumber = sins(counter);
        SinogramNumberStr = [ sprintf('%04d',sins(counter)) ];
        %% load image
        Filename = [ SampleName ProtocolName(whichone) '_conc' SinogramNumberStr '.rec.tif' ];
        loadpath = [ path SampleName ProtocolName(whichone) '_conc/rec/'];
        Image(:,:,counter) = double(imread([ loadpath num2str(Filename) ])) ./ 65535 ;
        
        %% load each protocol into separate image and calculate quadratic
        %% error on the fly, so we can plot it at the end...
        load = [ loadpath num2str(Filename) ];
        %% A%%
        if whichone == 1
            A(:,:,counter) = double(imread([ load ])) ./ 65535 ;
            if normalizeoriginals ==1;
                A(:,:,counter) = A(:,:,counter) - min(min(A(:,:,counter)));
                A(:,:,counter) = A(:,:,counter) / max(max(A(:,:,counter)));
            end
            DiffImageA(:,:,counter) = ( A(:,:,counter) - A(:,:,counter) ).^2;
            if normalize == 1
                DiffImageA(:,:,counter) = DiffImageA(:,:,counter) - min(min(DiffImageA(:,:,counter)));
                DiffImageA(:,:,counter) = DiffImageA(:,:,counter) / max(max(DiffImageA(:,:,counter)));
            end
            quadErrorA(counter) = sum( sum( DiffImageA(:,:,counter) ) );
        %% B %% 
        elseif whichone == 2
            B(:,:,counter) = double(imread([ load ])) ./ 65535 ;
            if normalizeoriginals == 1;
                B(:,:,counter) = B(:,:,counter) - min(min(B(:,:,counter)));
                B(:,:,counter) = B(:,:,counter) / max(max(B(:,:,counter)));
            end           
            DiffImageB(:,:,counter) = ( B(:,:,counter) - A(:,:,counter) ).^2;
            if normalize == 1
                DiffImageB(:,:,counter) = DiffImageB(:,:,counter) - min(min(DiffImageB(:,:,counter)));
                DiffImageB(:,:,counter) = DiffImageB(:,:,counter) / max(max(DiffImageB(:,:,counter)));
            end
            quadErrorB(counter) = sum( sum( DiffImageB(:,:,counter) ) );
        %% C %% 
        elseif whichone == 3
            C(:,:,counter) = double(imread([ load ])) ./ 65535 ;
            if normalizeoriginals == 1;
                C(:,:,counter) = C(:,:,counter) - min(min(C(:,:,counter)));
                C(:,:,counter) = C(:,:,counter) / max(max(C(:,:,counter)));
            end 
            DiffImageC(:,:,counter) = ( C(:,:,counter) - A(:,:,counter) ).^2;
            if normalize == 1
                DiffImageC(:,:,counter) = DiffImageC(:,:,counter) - min(min(DiffImageC(:,:,counter)));
                DiffImageC(:,:,counter) = DiffImageC(:,:,counter) / max(max(DiffImageC(:,:,counter)));
            end
            quadErrorC(counter) = sum( sum( DiffImageC(:,:,counter) ) );
        %% D %% 
        elseif whichone == 4
            D(:,:,counter) = double(imread([ load ])) ./ 65535 ;
            if normalizeoriginals == 1;
                D(:,:,counter) = D(:,:,counter) - min(min(D(:,:,counter)));
                D(:,:,counter) = D(:,:,counter) / max(max(D(:,:,counter)));
            end
            DiffImageD(:,:,counter) = ( D(:,:,counter) - A(:,:,counter) ).^2;
            if normalize == 1
                DiffImageD(:,:,counter) = DiffImageD(:,:,counter) - min(min(DiffImageD(:,:,counter)));
                DiffImageD(:,:,counter) = DiffImageD(:,:,counter) / max(max(DiffImageD(:,:,counter)));
            end
            quadErrorD(counter) = sum( sum( DiffImageD(:,:,counter) ) );
        %% E %%
        elseif whichone == 5
            E(:,:,counter) = double(imread([ load ])) ./ 65535 ;
            if normalizeoriginals == 1;
                E(:,:,counter) = E(:,:,counter) - min(min(E(:,:,counter)));
                E(:,:,counter) = E(:,:,counter) / max(max(E(:,:,counter)));
            end
            DiffImageE(:,:,counter) = ( E(:,:,counter) - A(:,:,counter) ).^2;
            if normalize == 1
                DiffImageE(:,:,counter) = DiffImageE(:,:,counter) - min(min(DiffImageE(:,:,counter)));
                DiffImageE(:,:,counter) = DiffImageE(:,:,counter) / max(max(DiffImageE(:,:,counter)));
            end
            quadErrorE(counter) = sum( sum( DiffImageE(:,:,counter) ) );
        %% F %% 
        elseif whichone == 6
            F(:,:,counter) = double(imread([ load ])) ./ 65535 ;
            if normalizeoriginals == 1;
                F(:,:,counter) = F(:,:,counter) - min(min(F(:,:,counter)));
                F(:,:,counter) = F(:,:,counter) / max(max(F(:,:,counter)));
            end
            DiffImageF(:,:,counter) = ( F(:,:,counter) - A(:,:,counter) ).^2;
            if normalize == 1
                DiffImageF(:,:,counter) = DiffImageF(:,:,counter) - min(min(DiffImageF(:,:,counter)));
                DiffImageF(:,:,counter) = DiffImageF(:,:,counter) / max(max(DiffImageF(:,:,counter)));
            end
            quadErrorF(counter) = sum( sum( DiffImageF(:,:,counter) ) );
        end
        if showimg == 1
            if SinogramNumber == showwhichimg
            figure(whichone);;
                subplot(121)
                    imagesc(Image(:,:,counter));
                    title({[ 'Protocol ' num2str(ProtocolName(whichone)) ' (Slice ' ...
                            num2str(SinogramNumber) ')' ];...
                            ['(' num2str(size(Image,1)) 'px x' num2str(size(Image,2)) 'px)']});
                    colormap gray;
                    axis image;
                    colorbar;
                subplot(122)
                    DiffImage(:,:,counter) = ( Image(:,:,counter) - A(:,:,counter) );
                    imagesc(DiffImage(:,:,counter));
                    title({['Difference Image of Protocol ' num2str(ProtocolName(whichone))...
                            ' with Protocol A (Slice ' num2str(SinogramNumber) ')'];
                            ['(' num2str(size(Image,1)) 'px x' num2str(size(Image,2)) 'px)']});
                    colormap gray;
                    axis image;
                    colorbar;
            end
        end
        disp(['done with Slice ' num2str(SinogramNumber)]);
    end
    toc;
    disp('');
    disp([ '--done with Protocol ' ProtocolName(whichone) '--']);
    disp('------------------------');
    
end

%% write single diff images to disk if wanted
if writediffimages == 1
    for j = ctr;
    imwrite(DiffImageA(:,:,j),[path '/comparison/_DiffAAslice' ...
        num2str(sprintf('%04d',sins(j))) '.tif'],'Compression','none');
    imwrite(DiffImageB(:,:,j),[path '/comparison/_DiffABslice' ...
        num2str(sprintf('%04d',sins(j))) '.tif'],'Compression','none');
    imwrite(DiffImageC(:,:,j),[path '/comparison/_DiffACslice' ...
        num2str(sprintf('%04d',sins(j))) '.tif'],'Compression','none');
    imwrite(DiffImageD(:,:,j),[path '/comparison/_DiffADslice' ...
        num2str(sprintf('%04d',sins(j))) '.tif'],'Compression','none');
    imwrite(DiffImageE(:,:,j),[path '/comparison/_DiffAEslice' ...
        num2str(sprintf('%04d',sins(j))) '.tif'],'Compression','none');
    imwrite(DiffImageF(:,:,j),[path '/comparison/_DiffAFslice' ...
        num2str(sprintf('%04d',sins(j))) '.tif'],'Compression','none');
    end
end
    
%% compute error
ERROR = [quadErrorA; quadErrorB; quadErrorC; quadErrorD; quadErrorE; quadErrorF]

%% Display Error Figure
figure;
    linemarker = ['+','o','*','x','s','d','p','h'];
    linecolor = ['r','g','b','c','m','y','k','r'];
    for i=1:size(ERROR,2)
        plot(Protocols',ERROR(:,i),[ '-' linemarker(i) linecolor(i) ]);
        hold on;
    end
    legend();
    title('quadratic Error for Protocols compared to `A` for all calculated Sinograms');
    xlabel('Protocol');
    ylabel('Error');
    set(gca,'XTick',[1 2 3 4 5 6]);
    set(gca,'XTickLabel',{'';'B';'C';'D';'E';'F'});
    legend(['Slice ' num2str(sins(1))],['Slice ' num2str(sins(2))],...
        ['Slice ' num2str(sins(3))],['Slice ' num2str(sins(4))],...
        ['Slice ' num2str(sins(5))],['Slice ' num2str(sins(6))],...
        ['Slice ' num2str(sins(7))],['Slice ' num2str(sins(8))],'Location','SouthEast');

AvgERROR = [ mean(ERROR(1,:)) ; mean(ERROR(2,:)) ; mean(ERROR(3,:)) ;...
             mean(ERROR(4,:)) ; mean(ERROR(5,:)) ; mean(ERROR(6,:)) ]
  
figure();
    plot(Protocols',AvgERROR);
    xlabel('Protocol');
    ylabel('Error');
    set(gca,'XTick',[1 2 3 4 5 6]);
    set(gca,'XTickLabel',{'';'B';'C';'D';'E';'F'});
    title('averaged quadratic Error for Protocols compared to `A`');
     
if printimg == 1
    print -f1 -deps /afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/comparison/DiffA;
    print -f2 -deps /afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/comparison/DiffB;
    print -f3 -deps /afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/comparison/DiffC;
    print -f4 -deps /afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/comparison/DiffD;
    print -f5 -deps /afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/comparison/DiffE;
    print -f6 -deps /afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/comparison/DiffF;
    print -f7 -depsc /afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/comparison/errorplot;
    print -f8 -depsc /afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/comparison/errorplotaverage;
end
    
%% Clear and finish
disp('Finished with everything you asked for.');
% clear all;