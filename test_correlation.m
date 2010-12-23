%% test the correlation
clear;
close all;
clc;

steps = 100;

a = ones(1,steps);
b = a;

a(1:10)=sin(0:pi/9:pi)+1;

b(56:65)=sin(0:pi/9:pi)+1;

figure
    subplot(211)
        plot(a)
    subplot(212)
        plot(b)
        
[corr,lags] = xcorr(b,a);
figure
    plot(corr)

%figure
%    stem(lags,corr)
    
%zerorow = zeros(1,3*size(a,2));
%a_pad = zerorow;
%a_pad(101:200) = a;
%b_pad = zerorow;
%b_pad(101:200) = b;

%figure
%    subplot(211)
%        plot(a_pad)
%    subplot(212)
%        plot(b_pad)

for i=1:steps-1
    shift_a=circshift(a,[0 i]);
    tmp = shift_a .* b;
    max(max(tmp))
    result(i,:)=tmp;
end

figure
    surface(result)
    grid on
    axis([ 0 100 0 100 0 4])
    view(0,90)