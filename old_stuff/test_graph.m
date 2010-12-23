clc;
clear;
close all;

Error = [   0   0   0
            10  20  30
            20  50  60
            30  60  70
            40  70  90
            50  15  100]
prot = [ 1, 2, 3 ,4, 5, 6]

figure
    plot(prot',Error(:,1),prot',Error(:,2),prot',Error(:,3))
    legend('a','b','c')