clc;clear all;close all;
h=[3, 1, 2, -4]; %channel
[x1 x2 x3 x4 y1 y2 y3 y4] = datagen(10,20,h,0);

figure
acf1=conv(x1,flipud(x1));
subplot(2,2,1);
plot(acf1,'ro','MarkerSize',15)
grid on;
ylim([-3 6])

acf2=conv(x2,flipud(x2));
subplot(2,2,2);
plot(acf2,'ro','MarkerSize',15)
grid on;
ylim([-3 6])

acf3=conv(x3,flipud(x3));
subplot(2,2,3);
plot(acf3,'ro','MarkerSize',15)
grid on;
ylim([-3 6])

acf4=conv(x4,flipud(x4));
subplot(2,2,4);
plot(acf3,'ro','MarkerSize',15)
grid on;
ylim([-3 6])