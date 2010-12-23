clear;
close all;
clc;

x = 3;
y = 2;
maxx = x;
maxy = y;
phantom =  phantom(64);

figure;

for i = 1:(x+1)
    for k = 1:(y+1)
        subplot(maxx,maxy,i+k-1);
        imshow(phantom);
        title(['phantom ' num2str(i+k-1) ]);
   end
end