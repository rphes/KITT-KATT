line='line';
LinePlotStyle=['''r''',',','''LineWidth''',',','2'];
N=100;
a=0.95;
h=filter(1, [1 a], [1 zeros(1,N-1)]);
figure(1)
subplot(2,1,1)
plot(h,LinePlotStyle)
title('First order IIR filter with a=0.95');
ylabel('h[n]');
xlabel('n');

figure(2)
H=fft(h);
subplot(2,1,1);
plot(0:2*pi/N:(N-1)*2*pi/N,abs(H))
ylabel('|H(j\omega)|');
xlabel('\omega');
title('Impulse response');
xlim([0 2*pi]);

figure(1)
a=-0.95;
h=filter(1, [1 a], [1 zeros(1,N-1)]);
subplot(2,1,2)
plot(h)
title('First order IIR filter with a=-0.95');
ylabel('h[n]');
xlabel('n');

figure(2)
H=fft(h);
subplot(2,1,2);
plot(0:2*pi/N:(N-1)*2*pi/N,abs(H))
ylabel('|H(j\omega)|');
xlabel('\omega');
title('Impulse response');
xlim([0 2*pi]);
