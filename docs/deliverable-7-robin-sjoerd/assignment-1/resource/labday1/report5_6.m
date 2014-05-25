h = [1 zeros(1,5) 0.9 zeros(1,5) 0.8];

padding = length(h)*4;
h_padded = [h zeros(1,padding)];

% Calculate frequencies
N = length(h);
w = [-0.5*((N-1)/N): 1/N: 0.5];
N_padded = length(h_padded);
w_padded = [-0.5*((N_padded-1)/N_padded): 1/N_padded: 0.5];

% FFT
H = fftshift(fft(h));
H_padded = fftshift(fft(h_padded));

% Plot
close all;
plot(w, abs(H), 'o','MarkerSize',15);

grid on;
xlabel 'Normalized frequency';
ylabel '|H[jw]|';
title 'FFT of impulse response';

%% run the following code for Report 6
hold on
plot(w_padded, abs(H_padded),'r','LineWidth',2)
plot(w_padded, abs(H_padded),'kx','MarkerSize',15)
