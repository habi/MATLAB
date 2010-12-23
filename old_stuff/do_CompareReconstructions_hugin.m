clear;
clc;
close all;

%% Set Parameters
Files = ['A','B','C','D','E','F'];
showsclices = 0;
printfigures = 1;
printdiffimages == 1;

for which =1:2   
    
    if which == 1
        SampleName = 'register';
        FileNumberStr = ['0000';'0001';'0002';'0003';'0004';'0005'];
        div = 2^8-1;
    elseif which == 2
        SampleName = 'R108C60_22_20x_';
        FileNumberStr = ['A_conc1023.rec';'B_conc1023.rec';'C_conc1023.rec';...
            'D_conc1023.rec';'E_conc1023.rec';'F_conc1023.rec',];
        div = 2^16-1;  
    end

%% set other needed parameters
    path = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/register/';

    for k = 1:length(Files)
        Image(:,:,k) = double(imread([ path SampleName FileNumberStr(k,:) '.tif' ])) ./ div;
        if showsclices == 1
            figure
                imshow(Image(:,:,k),[])
                axis image
                colormap gray
        end
    end

    % max=max(max(Image))
    % min=min(min(Image))

    for j=1:length(Files)
        figure
        titles=['A','B','C','D','E','F'];
            subplot(121)
                imagesc(Image(:,:,j))
                axis image
                axis off
                colormap(gray)
                colorbar
                title(titles(j))
            subplot(122)
                imagesc(Image(:,:,1) - Image(:,:,j))
                axis image
                colormap gray
                colorbar %('location','NorthOutside')
                title([SampleName ' - DiffImage of A & ' titles(j)])
        if printfigures == 1
            print('-depsc', [ path 'img/comparison-' num2str(Files(j)) '-' SampleName]);
        end
        if printdiffimages == 1
            Im2Write = Image(:,:,1) - Image(:,:,j);
            Im2Write = Im2Write - min(min(Im2Write));
            Im2Write = Im2Write ./ max(max(Im2Write));
            imwrite(Im2Write,[path 'img/_diff/' SampleName num2str(j) '.tif'],'Compression','none');
            clear Im2Write;
        end
    end
    
    quadErrorA = sum( sum( ( Image(:,:,1) - Image(:,:,1) ) .^2 ) );
    quadErrorB = sum( sum( ( Image(:,:,1) - Image(:,:,2) ) .^2 ) );
    quadErrorC = sum( sum( ( Image(:,:,1) - Image(:,:,3) ) .^2 ) );
    quadErrorD = sum( sum( ( Image(:,:,1) - Image(:,:,4) ) .^2 ) );
    quadErrorE = sum( sum( ( Image(:,:,1) - Image(:,:,5) ) .^2 ) );
    quadErrorF = sum( sum( ( Image(:,:,1) - Image(:,:,6) ) .^2 ) );
    
%% compute error
    if which == 1 
        ERROR1 = [quadErrorA; quadErrorB; quadErrorC; quadErrorD; quadErrorE; quadErrorF]
    elseif which ==2
        ERROR2 = [quadErrorA; quadErrorB; quadErrorC; quadErrorD; quadErrorE; quadErrorF]
    end
    
%% Display Error Figure1
    Files = [1,2,3,4,5,6];
    figure;
        if which == 1
            for i=1:size(ERROR1,2)
                plot(Files',ERROR1(:,i),'--x');
            end
        elseif which == 2
            for i=1:size(ERROR2,2)
                plot(Files',ERROR2(:,i),'--x');
            end
        end
                xlabel('Protocol');
                ylabel('quadratic Error');
                set(gca,'XTick',Files);
                set(gca,'XTickLabel',{'A';'B';'C';'D';'E';'F'});
                title(SampleName)
    if printfigures == 1
        print('-depsc', [ path 'img/_error-' SampleName]);
    end

    clear Image;

end

figure
    for i=1:size(ERROR1,2)
        plot(Files',ERROR1(:,i),'--x');
        hold on
        plot(Files',ERROR2(:,i),'--o');
    end
    xlabel('Protocol');
    ylabel('quadratic Error');
    set(gca,'XTick',Files);
    set(gca,'XTickLabel',{'A';'B';'C';'D';'E';'F'});
    title('Errors for Registered and Unregistered images')
    legend('registered','unregistered','location','SouthEast');
if printfigures == 1
    print('-depsc', [ path 'img/_both_errors']);
end

%% Clear and finish
disp('Finished with everything you asked for.');
clear all;