close all;
clear;
clc;

unregistered = imread('westconcordaerial.png');
figure, imshow(unregistered)

registeredOriginal = imread('westconcordorthophoto.png');
figure, imshow(registeredOriginal)

load westconcordpoints % load some points that were already picked
cpselect(unregistered(:,:,1),'westconcordorthophoto.png',...
         input_points,base_points)
     
t_concord = cp2tform(input_points,base_points,'projective');    
     
info = imfinfo('westconcordorthophoto.png');
registered = imtransform(unregistered,t_concord,...
                         'XData',[1 info.Width], 'YData',[1 info.Height]);    
     
     
   figure, imshow(registered)  
     
     