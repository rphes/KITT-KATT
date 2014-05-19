%% Report 7
load train %y=samples, Fs = samplerate
x=y'; %naming convention
h=[1 zeros(1,5) 0.9 zeros(1,5) 0.8];

Y_conv = fft(conv(x,h));

new_length = length(x)+length(h)-1;
x = [x zeros(1,new_length-length(x))];
h = [h zeros(1,new_length-length(h))];
N=length(x);
Y_fft = fft(x).*fft(h);

F = [0: 2*pi/N:(N-1)*2*pi/N];

% subplot(3,1,1);
% plot(abs(Y_fft),'r','LineWidth',1);
% subplot(3,1,2);
% plot(abs(Y_conv),'r','LineWidth',1);
% subplot(3,1,3);
plot(fftshift(F)-pi,fftshift(abs(Y_conv-Y_fft)),'b','LineWidth',1);
title('Absolute difference between fft(conv(x,h)) and fft(x)*fft(h)');
xlabel('Frequency');
ylabel('|Y(j\omega)|');
