%% report 3
clc;clear all;close all;
load train; %stores train in y and samplerate in Fs
p=audioplayer(y,Fs);
N=p.TotalSamples;
%play(p)
dT=1/Fs;
T=1/Fs*(N-1);
time=0:dT:T;
plot(time,y)
xlabel('Time [s]');
ylabel('Relative amplitude');

%% fft
Y=fft(y);
% figure
% plot(abs(Y));
fftshift(Y);
Omega = [-pi: 2*pi/N:(N-1)*pi/N];
f = Omega*Fs;
figure
plot(f, abs(Y))
xlabel('Frequency (\omega) [Hz]');
ylabel('|Y(j\omega)|');