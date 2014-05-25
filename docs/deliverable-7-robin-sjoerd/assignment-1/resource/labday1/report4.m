%% report 4
clc;clear all;close all;
load train; %stores train in y and samplerate in Fs
p=audioplayer(y,Fs);
N=p.TotalSamples;
% play(p)
dT=1/Fs;
T=1/Fs*(N-1);
time=0:dT:T;
%in 20 ms: SampleRate / 50 samples
SamplesPer20ms = ceil(Fs/50)
NumberOfTimeSlots = ceil(N/SamplesPer20ms)

y=[y;zeros(NumberOfTimeSlots*SamplesPer20ms-length(y),1)];
x=reshape(y,SamplesPer20ms,NumberOfTimeSlots);
X=fft(x);
%hieronder klopt iets volgens mij niet... de f schaal ?
t=0:20e-3:T;
f=-Fs/2:Fs/2; %Nyquist criterium says highest frequency <= 0.5* samplerate
omega=-pi:2*pi/SamplesPer20ms:pi*(SamplesPer20ms-1)/SamplesPer20ms;
f=omega*Fs/2;
imagesc(t,f,abs(X))%,[0 25])
xlabel('time [s]');
ylabel('frequency [Hz]');
title('Frequency occurrence in 20 ms intervals');