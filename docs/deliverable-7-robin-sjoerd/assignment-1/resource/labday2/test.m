clc;clear all;close all;
h=[3, 1, 2, -4]; %channel
%plot the channel
plot_channel_estimate(h,0,0,'Original channel $$h$$[n]')

[x1 x2 x3 x4 y1 y2 y3 y4] = datagen(10,30,h,0)
%NOTE: L is the channel length. If you choose L>4 you will see that
%the terms in the channel estimate become zero. This is desired because
%we have set h to have only 4 elements..
L = 10;
% ch1(x1,y1,L)
% ch1(x2,y2)
% ch1(x3,y3)
ch1(x4,y4,L)
% 
% ch2(x1,y1,0)
% ch2(x2,y2,0)
% ch2(x3,y3,0)
ch2(x4,y4,0)

