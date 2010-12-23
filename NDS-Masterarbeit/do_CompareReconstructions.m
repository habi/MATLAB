clear;
clc;
close all;
time1 = clock;

%% Set Parameters
showwhichimg = 512;
resize = [ 64 64 ];

showimg = 1;
printimg = 1; %only works if showimg = 1...
writediffimages = 1;

normalize = 0;
normalizeoriginals = 0;

%% set other needed parameters
SampleName = 'R108C60_22_20x_';
ProtocolName = ['A','B','C','D','E','F'];
sins = [1,256,511,512,766,768,1021,1023];

%tmp
%sins = [ 1 ]
%tmp

path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/';

for whichone = 1:1%length(ProtocolName) % which protocol
    Protocols(whichone)=whichone;
    tic;
    disp([ '-working on Protocol ' ProtocolName(whichone) '-']);
    ctr = 1:length(sins);
    for counter=ctr % which sinogram/slice? using ctr to we can reuse it below...
        SinogramNumber = sins(counter);
        SinogramNumberStr = [ sprintf('%04d',sins(counter)) ];
        %% load image
        Filename = [ SampleName ProtocolName(whichone) '_conc' SinogramNumberStr '.rec.DMP' ];
        loadpath = [ path SampleName ProtocolName(whichone) '_conc/rec/'];
        TMPIMAGE = double(readDumpImage([ loadpath num2str(Filename) ]));
        TMPIMAGE = imresize(TMPIMAGE,resize,'nearest');
        Image(:,:,counter) = TMPIMAGE;
        %% load each protocol into separate image and calculate quadratic
        %% error on the fly, so we can plot it at the end...
        load = [ loadpath num2str(Filename) ];
        %% A%%
        if whichone == 1
            TMPIMAGE = double(readDumpImage([ load ]));
            TMPIMAGE = imresize(TMPIMAGE,resize,'nearest');
            A(:,:,counter) = TMPIMAGE;
            clear TMPIMAGE;
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
            pixelErrorA(counter) = quadErrorA(counter) / ( size(A,1) * size(A,2) );
        %% B %% 
        elseif whichone == 2
            TMPIMAGE = double(readDumpImage([ load ]));
            TMPIMAGE = imresize(TMPIMAGE,resize,'nearest');
            B(:,:,counter) = TMPIMAGE;
            clear TMPIMAGE;
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
            pixelErrorB(counter) = quadErrorB(counter) / ( size(B,1) * size(B,2) );
        %% C %% 
        elseif whichone == 3
            TMPIMAGE = double(readDumpImage([ load ]));
            TMPIMAGE = imresize(TMPIMAGE,resize);
            C(:,:,counter) = TMPIMAGE;
            clear TMPIMAGE;
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
            pixelErrorC(counter) = quadErrorC(counter) / ( size(C,1) * size(C,2) );            
        %% D %% 
        elseif whichone == 4
            TMPIMAGE = double(readDumpImage([ load ]));
            TMPIMAGE = imresize(TMPIMAGE,resize);
            D(:,:,counter) = TMPIMAGE;
            clear TMPIMAGE;
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
            pixelErrorD(counter) = quadErrorD(counter) / ( size(D,1) * size(D,2) );    
        %% E %%
        elseif whichone == 5
            TMPIMAGE = double(readDumpImage([ load ]));
            TMPIMAGE = imresize(TMPIMAGE,resize);
            E(:,:,counter) = TMPIMAGE;
            clear TMPIMAGE;
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
            pixelErrorE(counter) = quadErrorE(counter) / ( size(E,1) * size(E,2) );    
        %% F %% 
        elseif whichone == 6
            TMPIMAGE = double(readDumpImage([ load ]));
            TMPIMAGE = imresize(TMPIMAGE,resize);
            F(:,:,counter) = TMPIMAGE;
            clear TMPIMAGE;
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
            pixelErrorF(counter) = quadErrorF(counter) / ( size(F,1) * size(F,2) );    
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

clear DiffImageA;
clear DiffImageB;
clear DiffImageC;
clear DiffImageD;
clear DiffImageE;
clear DiffImageF;

clear A;
clear B;
clear C;
clear D;
clear E;
clear F;

%% compute error
ERROR = [quadErrorA; quadErrorB; quadErrorC; quadErrorD; quadErrorE; quadErrorF]

%% Display Error Figure
figure(7);
    linemarker = ['+','o','*','x','s','d','p','h'];
    linecolor = ['r','g','b','c','m','y','k','r'];
    for i=1:size(ERROR,2)
        plot(Protocols,ERROR(:,i),[ '-' linemarker(i) linecolor(i) ]);
        hold on;
    end
    hold off;
%     set(gca,'YScale','log')
    set(gca,'YGrid','on')
    title('quadratic Error for Protocols compared to `A` for all calculated Sinograms');
    xlabel('Protocol');
    ylabel('Error');
    set(gca,'XTick',[1 2 3 4 5 6]);
    set(gca,'XTickLabel',{'';'B';'C';'D';'E';'F'});
    legend(['Slice ' num2str(sins(1))],['Slice ' num2str(sins(2))],...
        ['Slice ' num2str(sins(3))],['Slice ' num2str(sins(4))],...
        ['Slice ' num2str(sins(5))],['Slice ' num2str(sins(6))],...
        ['Slice ' num2str(sins(7))],['Slice ' num2str(sins(8))],'Location','SouthEast');

AvgERROR = mean(ERROR,2)
  
figure(8);
    plot(Protocols,AvgERROR);
    errorbar(Protocols,AvgERROR,[ std(ERROR(1,:)) std(ERROR(2,:)) std(ERROR(3,:)) std(ERROR(4,:)) std(ERROR(5,:)) std(ERROR(6,:)) ] );
    %     set(gca,'YScale','log')
    set(gca,'YGrid','on')
    title('quadratic Error for Protocols compared to `A` for all calculated Sinograms');
    xlabel('Protocol');
    ylabel('Average Error');
    set(gca,'XTick',[1 2 3 4 5 6]);
    set(gca,'XTickLabel',{'';'B';'C';'D';'E';'F'});
    title([{'averaged quadratic Error for Protocols compared to `A`'}...
           {'Errorbars are StandardDeviation of the Error of the slices'}]);
    
PixelERROR = [ pixelErrorA ; pixelErrorB ; pixelErrorC ; pixelErrorD; pixelErrorE; pixelErrorF ]

figure(9);
    plot(Protocols',PixelERROR);
    xlabel('Protocol');
    ylabel('Pixel Error');
    set(gca,'XTick',[1 2 3 4 5 6]);
    set(gca,'XTickLabel',{'';'B';'C';'D';'E';'F'});
    title('Error per Pixel for Protocols compared to `A`');


if printimg == 1
    print -f1 -deps /afs/psi.ch/user/h/haberthuer/MATLAB/img/DiffA;
    print -f2 -deps /afs/psi.ch/user/h/haberthuer/MATLAB/img/DiffB;
    print -f3 -deps /afs/psi.ch/user/h/haberthuer/MATLAB/img/DiffC;
    print -f4 -deps /afs/psi.ch/user/h/haberthuer/MATLAB/img/DiffD;
    print -f5 -deps /afs/psi.ch/user/h/haberthuer/MATLAB/img/DiffE;
    print -f6 -deps /afs/psi.ch/user/h/haberthuer/MATLAB/img/DiffF;
    print -f7 -depsc /afs/psi.ch/user/h/haberthuer/MATLAB/img/errorplot;
    print -f8 -depsc /afs/psi.ch/user/h/haberthuer/MATLAB/img/errorplotaverage;
    print -f9 -depsc /afs/psi.ch/user/h/haberthuer/MATLAB/img/errorplotpixel;
end
    
%% Clear and finish
disp('Finished with everything you asked for.');
time2 = clock
usedtime = time2 - time1;
disp(['it took me ' num2str(usedtime(3)) ' days, '  num2str(usedtime(4)) ...
    ' hours, ' num2str(usedtime(5)) ' minutes and ' num2str(usedtime(6)) ' seconds']);