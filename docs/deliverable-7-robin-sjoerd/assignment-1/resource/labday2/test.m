clc;clear all;close all;
h=[3, 1, 2, -4]; %channel
%plot the channel
figure
plot(h,'ro','MarkerSize',15,'MarkerFaceColor','r')
ylim([min(h-1) max(h+1)])
xlim([0 length(h)+1])
%draw lines to x axis
for i=1:length(h)
    line([i i],[0 h(i)],'LineStyle','-','LineWidth',2,'Color','r')
end
%draw x axis
line([0 length(h)+1],[0 0],'LineStyle','-','LineWidth',2)

[x1 x2 x3 x4 y1 y2 y3 y4] = datagen(10,30,h,0)
%NOTE: L is the channel length. If you choose L>5 you will see that
%the terms in the channel estimate become zero. This is desired because
%we have set h to have only 4 elements..
L = 10;
est1=ch1(x1,y1,L)
% ch1(x2,y2)
% ch1(x3,y3)
% ch1(x4,y4)
% 
ch2(x1,y1,L)
% ch2(x2,y2)
% ch2(x3,y3)
% ch2(x4,y4)

