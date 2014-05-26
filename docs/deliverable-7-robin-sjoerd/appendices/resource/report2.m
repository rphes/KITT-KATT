%% sequence
close all;
%% filter
N=100;
%a=0.95
a=0.95;
h1=filter(1, [1 a], [1 zeros(1,N-1)]);
subplot(2,1,1)
plot(h1)
%a=-0.95
a=-0.95;
h2=filter(1, [1 a], [1 zeros(1,N-1)]);
subplot(2,1,2)
plot(h2)

%% FFT
H1=fft(h1);
figure
plot(0:2*pi/N:(N-1)*2*pi/N,abs(H1))

H2=fft(h2);
figure
plot(0:2*pi/N:(N-1)*2*pi/N,abs(H2))