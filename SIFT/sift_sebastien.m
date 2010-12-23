clc;clear all;close all
% --------------------------------------------------------------------
%                                                    Create image pair
% --------------------------------------------------------------------

Pair = [58,830];

disp(['Loading LM-Image ' num2str(Pair(1)) ' and TOMCAT-Image ' ...
    num2str(Pair(2)) ]);
Ia = imread(['\\anadata\U\Gruppe_Schittny\images\Sebastien\FotosR108C21C\R108C21C-' ...
    sprintf('%03d',Pair(1)) '.tif']);
Ib = imread(['s:\SLS\2008c\mrg\R108C21Cc_mrg\rec_8bit\R108C21Cc_mrg' ...
    sprintf('%04d',Pair(2)) '.rec.8bit.tif']);

Ib = imcomplement(Ib);

Ia = single(Ia);
Ib = single(Ib);

%Ia = imresize(Ia,[1024 1200]);
%Ib = imresize(Ib,[1024 1200]);

% --------------------------------------------------------------------
%                                           Extract features and match
% --------------------------------------------------------------------

disp('Calculating Keypoints')
[fa,da] = vl_sift(Ia);
[fb,db] = vl_sift(Ib);

disp('Matching and Sorting Keypoints')
[matches, scores] = vl_ubcmatch(da,db);

[drop, perm] = sort(scores, 'descend');
matches = matches(:, perm);
scores  = scores(perm);

% xa = fa(1,matches(1,:));
% xb = fb(1,matches(2,:));
% ya = fa(2,matches(1,:));
% yb = fb(2,matches(2,:));

figure('name',['LM-Image ' num2str(Pair(1)) ' matched with TOMCAT-Image ' ...
    num2str(Pair(2))]);
    subplot(211)
        hold on;
        imshow(Ia,[])
        vl_plotframe(fa(:,matches(1,:)));
        title(['Size: ' num2str(size(Ia,1)) 'x' num2str(size(Ia,2)) ])
    subplot(212)
        hold on
        imshow(Ib,[])
        vl_plotframe(fb(:,matches(2,:)));
        title(['Size: ' num2str(size(Ib,1)) 'x' num2str(size(Ib,2)) ])