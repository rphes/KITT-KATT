% Config
Fs_TX = 22050;
Fs_RX = 22050;

A = 1;
t = 1;

% Create signal
x = A*[zeros(1,round(t/2*Fs_TX)) 1 zeros(1,round(t/2*Fs_TX))];
t_act = length(x)/Fs_TX;

% Play and record
xrec = audioplayer(x, Fs_TX);
yrec = audiorecorder(Fs_TX, 16, 1); % 16 bits, 1 channel

display 'Begin of recording';
record(yrec);
play(xrec);
pause(t_act);
stop(yrec);
display 'End of recording';

% Process
y = getaudiodata(yrec);
N = length(y);
W = [-pi*((N-1)/N): 2*pi/N: pi]; % Genormaliseerd
F = W/2/pi*Fs_RX/1000; % Niet genormaliseerd
H = fftshift(fft(y));

% Plot
subplot(3,1,1);
plot((1:length(x))/Fs_TX,x);
xlabel 'Time (s)';
ylabel 'Amplitude';
title 'Sent-out signal';

% Find impulse response
A_find = 0.5;
t_frame = 0.045;
t_frame_ratio = 0.95;

t_found = 0;
for i = 1:length(y)
    if (y(i) >= A_find) && (i >= round(length(y)/2))
        t_found = i/Fs_RX;
        break;
    end
end

subplot(3,1,2);
plot((1:length(y))/Fs_RX,y);
xlim([t_found-t_frame*(1-t_frame_ratio) t_found+t_frame*t_frame_ratio]);
xlabel 'Time (s)';
ylabel 'Amplitude';
title 'Received signal';

subplot(3,1,3);
plot(F,abs(H));
ylabel '|H(w)|';
xlabel 'Frequency (kHz)';
title 'Spectrum of received signal';


