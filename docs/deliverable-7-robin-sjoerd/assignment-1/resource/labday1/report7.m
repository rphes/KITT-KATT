%% Report 7
load train %y=samples, Fs = samplerate
x=y'; %naming convention
h=[1 zeros(1,5) 0.9 zeros(1,5) 0.8];

Y_conv = fft(conv(x,h));

N = length(x)+length(h)-1;
x = [x zeros(1,N-length(x))];
h = [h zeros(1,N-length(h))];
Y_fft = fft(x).*fft(h);

F = [-pi: 2*pi/N:(N-1)*pi/N];

subplot(3,1,1);
plot(F,abs(Y_conv),'r','LineWidth',2);
xlabel('Frequency');
ylabel('|F(x*h)|')
xlim([-pi pi]);
subplot(3,1,2);
plot(F,abs(Y_fft),'r','LineWidth',2);
xlabel('Frequency');
ylabel('|F(x)F(h)|')
xlim([-pi pi]);
subplot(3,1,3);
plot(F,abs(Y_conv-Y_fft),'b','LineWidth',2)
xlabel('Frequency');
ylabel('|F(x*h)-F(x)F(h)|');
xlim([-pi pi]);
%NOTE: the algorithm works fine, but the plots are not beautiful yet..