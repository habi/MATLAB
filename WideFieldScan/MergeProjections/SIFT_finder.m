%% SIFT-Test
% Testing SIFT-algorithm from http://www.vlfeat.org/
clc;clear all;close all
warning off Images:initSize:adjustingMag % suppress the warning about big images, they are still displayed correctly, just a bit smaller..
tic

%% Setup
MatchingThreshold = 2.5; %Threshold for SIFT-Matching 
Factor = 15; % "Rounding" Factor for "are keypoints on the same height"?
shift = 2; % Shift inbetween figures

mkdir('C:\Documents and Settings\haberthuer\Desktop\sift')
%% Load Files
counter=0;
DarkA = double(imread('R:\SLS\2010b\R108C04Aa_B1_s1_\tif\R108C04Aa_B1_s1_0004.tif'));
DarkB = double(imread('R:\SLS\2010b\R108C04Aa_B1_s2_\tif\R108C04Aa_B1_s2_0004.tif'));
DarkC = double(imread('R:\SLS\2010b\R108C04Aa_B1_s3_\tif\R108C04Aa_B1_s3_0004.tif'));
FlatA = double(imread('R:\SLS\2010b\R108C04Aa_B1_s1_\tif\R108C04Aa_B1_s1_0040.tif'));
FlatB = double(imread('R:\SLS\2010b\R108C04Aa_B1_s2_\tif\R108C04Aa_B1_s2_0040.tif'));
FlatC = double(imread('R:\SLS\2010b\R108C04Aa_B1_s3_\tif\R108C04Aa_B1_s3_0040.tif'));
for i=100:100:3638
    counter = counter + 1;
    disp(['Working on projection ' num2str(i) ])
    disp('Reading Files')
    ImageA = double(imread(['R:\SLS\2010b\R108C04Aa_B1_s1_\tif\R108C04Aa_B1_s1_' sprintf('%04d',i) '.tif']));
    ImageB = double(imread(['R:\SLS\2010b\R108C04Aa_B1_s2_\tif\R108C04Aa_B1_s2_' sprintf('%04d',i) '.tif']));
    ImageC = double(imread(['R:\SLS\2010b\R108C04Aa_B1_s3_\tif\R108C04Aa_B1_s3_' sprintf('%04d',i) '.tif']));
	ImageA = mat2gray(log(FlatA-DarkA)-log(ImageA-DarkA));
	ImageB = mat2gray(log(FlatB-DarkB)-log(ImageB-DarkB));
	ImageC = mat2gray(log(FlatC-DarkC)-log(ImageC-DarkC));
    
    %% Prepare Images for SIFT
    ImageA = single(ImageA);
    ImageB = single(ImageB);
    ImageC = single(ImageC);       

% % % % % % %     %Crop Images
% % % % % % %     CropTo = size(ImageA,1)/2;
% % % % % % %     ImageA = ImageA(:,end-CropTo+1:end);
% % % % % % %     ImageB = ImageB(:,1:CropTo);
% % % % % % %     ImageC = ImageC(:,1:CropTo);

    %% Calculate SIFT
    disp('Calculating SIFT')
    [KeyA, DescriptorA] = vl_sift(ImageA);
    [KeyB, DescriptorB] = vl_sift(ImageB);
    [KeyC, DescriptorC] = vl_sift(ImageC);
    [MatchesAB ScoresAB] = vl_ubcmatch(DescriptorA,DescriptorB,MatchingThreshold);
    [MatchesBC ScoresBC] = vl_ubcmatch(DescriptorB,DescriptorC,MatchingThreshold);
    %[drop, perm] = sort(ScoresAB, 'descend');
    %MatchesAB = MatchesAB(:,perm);
    %ScoresAB  = ScoresAB(perm);

    %% Prepare Figure
    %Calculate stuff for figure
    xab = KeyA(1,MatchesAB(1,:));
    xba = KeyB(1,MatchesAB(2,:));
    xbc = KeyB(1,MatchesBC(1,:));
    xcb = KeyC(1,MatchesBC(2,:));
    yab = KeyA(2,MatchesAB(1,:));
    yba = KeyB(2,MatchesAB(2,:));
    ybc = KeyB(2,MatchesBC(1,:));
    ycb = KeyC(2,MatchesBC(2,:));
    equalYab=eq(round(yab/Factor),round(yba/Factor));
    equalYbc=eq(round(ybc/Factor),round(ycb/Factor));
	disp(['1<->2: Found ' num2str(size(yab,2)) ' keypoints, of which ' num2str(sum(equalYab)) ' are on the same height.'])
    disp(['2<->3: Found ' num2str(size(ybc,2)) ' keypoints, of which ' num2str(sum(equalYbc)) ' are on the same height.'])
    xab = xab(equalYab);
    xba = xba(equalYab);
    xbc = xbc(equalYbc);
    xcb = xcb(equalYbc);
    yab = yab(equalYab);
    yba = yba(equalYab);
    ybc = ybc(equalYbc);
    ycb = ycb(equalYbc);  
    CutlineAB(counter)=round(mean(xab));
    CutlineBA(counter)=round(mean(xba));
    CutlineBC(counter)=round(mean(xbc));
    CutlineCB(counter)=round(mean(xcb));
    xba = xba + size(ImageA,2) + shift;;
    xbc = xbc + size(ImageA,2) + shift;;
    xcb = xcb + 2* (size(ImageA,2) + shift);
    KeyB(1,:) = KeyB(1,:) + size(ImageA,2) + shift;
    KeyC(1,:) = KeyC(1,:) + 2*(size(ImageA,2) + shift);
    if isnan(CutlineAB(counter)) | isnan(CutlineBA(counter)) | isnan(CutlineBC(counter)) | isnan(CutlineCB(counter))
        disp(['No cutline found!'])
        Cutline1(i) = 1;
        Cutline2(i)= Cutline1(counter);
        MergedProjection = [ ImageA zeros(size(ImageA,1),shift) ImageB zeros(size(ImageA,1),shift) ImageC ];
    else
        disp(['1<->2: Cutline left is ' num2str(CutlineAB(counter)) ', cutline right is ' num2str(CutlineBA(counter)) ]);
        Cutline1(i) = size(ImageA,2)-CutlineAB(counter)+CutlineBA(counter);
        disp(['       We are thus cutting ' num2str(Cutline1(i)) ' pixels from the right side of ImageA' ]);
        disp(['2<->3: Cutline left is ' num2str(CutlineBC(counter)) ', cutline right is ' num2str(CutlineCB(counter)) ]);
        Cutline2(i) = size(ImageA,2)-CutlineBC(counter)+CutlineCB(counter);
        disp(['       We are thus cutting ' num2str(Cutline2(i)) ' pixels from the left side of ImageA' ]);  
        MergedProjection = [ ImageA(:,1:end-Cutline1(i)) ImageB  ImageC(:,Cutline2(i):end) ];
    end
    figure(i)
        Screen = [ -21 -21 1700 1070 ];
        set(i,'Position',Screen)
        imshow([ ImageA zeros(size(ImageA,1),shift) ImageB zeros(size(ImageA,1),shift) ImageC ],[],'InitialMagnification','fit');
            hold on;
            h = line([xab; xba], [yab; yba]);
                set(h,'linewidth', 2, 'color', 'r');
            m = line([xbc; xcb], [ybc; ycb]);
                set(m,'linewidth', 2, 'color', 'g');
            vl_plotframe(KeyA(:,MatchesAB(1,:)),'b');
            vl_plotframe(KeyB(:,MatchesAB(2,:)),'c');
            vl_plotframe(KeyB(:,MatchesBC(1,:)),'m');
            vl_plotframe(KeyC(:,MatchesBC(2,:)),'y');
            title('Projections with Keypoints')
    filename = [ 'C:\Documents and Settings\haberthuer\Desktop\sift' filesep 'Fig' sprintf('%04d',i) '.png'];
    print('-dpng',filename);
    close(i)
    figure(i+1)
        set(i+1,'Position',Screen)
        imshow(MergedProjection,[],'InitialMagnification','fit');
        if isnan(CutlineAB(counter)) | isnan(CutlineBA(counter)) | isnan(CutlineBC(counter)) | isnan(CutlineCB(counter))
            title('Merging not possible')
        else
            title('Merged Projections')
        end
	filename = [ 'C:\Documents and Settings\haberthuer\Desktop\sift' filesep 'Mrg' sprintf('%04d',i) '.png'];
    print('-dpng',filename);
    pause(0.1)
    disp('---')
end
meanCutlineAB = round(mean(Cutline1(Cutline1>1)));
meanCutlineBA = round(mean(Cutline2(Cutline2>1)));

disp(['The mean cutline for 1<->2 (for all the valid ones) is ' num2str(meanCutlineAB) ]);
disp(['The mean cutline for 2<->3 (for all the valid ones) is ' num2str(meanCutlineBA) ]);
figure
    plot(Cutline1,'g')
    hold on
    plot(Cutline2,'r')
    title('Green: Cutline 1<->2, Red: Cutline 2<->3')
toc