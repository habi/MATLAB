%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fibonacci-Folge visualisiert
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;clear all;close all

k = 13;

f = ones(1,k);
f(1) = 0;
f(2) = 1;

for n = 3:k
    f(n) = f(n-1) + f(n-2);
end

Image = [];

for n = 1:k
    disp(['f(' num2str(n) ')= ' num2str(f(n)) ', Breite: ' num2str(f(n)+1) 'px' ])
    TMP(1:round(sum(f)*.0618),1:f(n)+1) = mod(n+1,2);
    Image = [ Image TMP ];
    clear TMP
end

figure
    imshow(Image,[])
    axis on
    title('Fibonacci')
    
imwrite(Image,'C:\Users\haberthuer\Desktop\fibonacci.png')
   