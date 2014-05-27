clear; clc; close all;
doload = 0;

%% Config
if doload == 0
    settings = struct();
    settings.Fs_RX = 22050; % reception sampling rate
    settings.Fs_TX = 22050; % transmission sampling rate
    settings.t_TX = 2;      % signal length
    settings.A = 0.5;       % signal amplitude
    
    settings.mode = 4;
    % 0: single pulse
    % 1: random pulses
    settings.t_impulse_TX = 0.1;    % impulse duration
    % 2: periodic pulses
    settings.t_interval = 1/1000;   % pulse interval
    % 3: sine
    settings.t_freq = 2500;          % sine frequency
    % 4: train
    % 5: handel
else
   load('measurement');
end

%% Create signal

if settings.mode == 0
    x = zeros(1,settings.t_TX*settings.Fs_TX);
    x(round(length(x)/2)) = settings.A;
elseif settings.mode == 1
    x = zeros(1,settings.t_TX*settings.Fs_TX);
   
    for i = 0:(settings.t_impulse_TX*settings.Fs_TX):((settings.t_TX-settings.t_impulse_TX)*settings.Fs_TX)
        first = i+1;
        last = i+settings.t_impulse_TX*settings.Fs_TX;

        % Begin pulse: first
        % End pulse: last

        if rand() >= 0.5
            x(first:last) = settings.A;
        else
            x(first:last) = 0;
        end
    end
elseif settings.mode == 2
    x = zeros(1,settings.t_TX*settings.Fs_TX);
    
    for i = 0:length(x)-1
        if mod(i, round(settings.Fs_TX*settings.t_interval)) == 0
            x(i+1) = settings.A; 
        end
    end
elseif settings.mode == 3
    x = 1:(settings.Fs_TX*settings.t_TX);
    x = settings.A*sin(2*pi*settings.t_freq*x/settings.Fs_TX);
elseif settings.mode == 4
    p = load('train');
    x = p.y;
elseif settings.mode == 5
    p = load('handel');
    x = p.y;
end

%% Play and record
xrec = audioplayer(x, settings.Fs_TX);
yrec = audiorecorder(settings.Fs_RX, 16, 1); % 16 bits, 1 channel

display 'Begin of recording';
record(yrec);
play(xrec);
pause(settings.t_TX);
stop(yrec);
stop(xrec);
display 'End of recording';

%% Playback
doplay = 1;
if (doplay == 1)
    display 'Playback';
    play(yrec);
end

%% Process
y = getaudiodata(yrec);
N = length(y);
W = [-pi*((N-1)/N): 2*pi/N: pi];
F = W/2/pi;
H = fftshift(fft(y));

%% Plot
subplot(3,1,1);
plot((1:length(x))/settings.Fs_TX,x);
xlabel 'Time (s)';
ylabel 'Amplitude';
title 'Sent out signal';

subplot(3,1,2);
plot((1:length(y))/settings.Fs_RX,y);
xlim([0 settings.t_TX]);
xlabel 'Time (s)';
ylabel 'Amplitude';
title 'Received signal';

subplot(3,1,3);
plot(F*settings.Fs_RX/1000,abs(H));
ylabel '|H(w)|';
xlabel 'Frequency (kHz)';
title 'Spectrum of received signal';

%% Save data
save measurement.mat settings x y F H;


