h = [1 zeros(1,5) 0.9 zeros(1,5) 0.8];

padding = length(h)*4;
h_padded = [h zeros(1,padding)];

% Calculate frequencies
N = length(h);
w = [-pi*((N-1)/N): 2*pi/N: pi]'
N_padded = length(h_padded);
w_padded = [-pi*((N_padded-1)/N_padded): 2*pi/N_padded: pi];

% FFT
H = fftshift(fft(h));
H_padded = fftshift(fft(h_padded));

% Plot
close all;
plot(w_padded/2/pi, abs(H_padded), '-x', w/2/pi, abs(H), '-o');
grid on;
xlabel 'Normalized frequency';
ylabel '|H[jw]|';
title 'FFT of impulse response';


close all;

addpath('../../../../../EPO-4 Personal/repo/src/UBERGRAPH/');

x = {w_padded/2/pi,w/2/pi};
y = {abs(H_padded),abs(H)};
LineStyle = {'-','-'};
LineMode = {'stem','stem'};
LineWidth = [1.5;1.5];
LineColor = [[1 0 0];[0 1 0]];
MarkerStyle = {'o','x'};
MarkerFaceColor = [[1 0 0];[0 1 0]];
MarkerEdgeColor = [[1 0 0];[0 1 0]];
MarkerSize = [8;8];
legendText = {'5 \cdot13 samples','13 samples'};
makeLegend = 'yes';
legendLocation = 'northEast';
logX = 0;

XTicks = 'auto';
YTicks = 'auto';
outputPath = 'output/ass-1-report-5'; % 'off' to disable outputting
graphTitle = 'Effect of zero padding';
yLabel = '|H(\omega)|';
xLabel = 'Normalized frequency';
xLim = 'auto';
yLim = 'auto';

uber_graph;