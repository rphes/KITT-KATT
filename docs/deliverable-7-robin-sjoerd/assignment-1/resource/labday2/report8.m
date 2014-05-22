clc;clear all;close all;
h=[3, 1, 2, -4]; %channel
UsefulLength=10;
TotalLength=20;
[x1 x2 x3 x4 y1 y2 y3 y4] = datagen(UsefulLength,TotalLength,h,0);

figure
acf1=xcorr(x1);
subplot(2,2,1);
plot_channel_estimate(acf1,'Time delay','Auto correlation','Minimum phase sequence');

acf2=conv(x2,flipud(x2));
subplot(2,2,2);
plot_channel_estimate(acf2,'Time delay','Auto correlation','Maximum phase sequence');

acf3=conv(x3,flipud(x3));
subplot(2,2,3);
plot_channel_estimate(acf3,'Time delay','Auto correlation','Sinusoidal signal');

acf4=xcorr(x4);
subplot(2,2,4);
plot_channel_estimate(acf4,'Time delay','Auto correlation','Random BPSK sequence');
