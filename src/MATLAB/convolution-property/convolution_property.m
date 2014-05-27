% Load train
load train
N = length(y);

h = [1 zeros(1,5) 0.9 zeros(1,5) 0.8];
h = [h zeros(1,N-length(h))];
w1 = [-pi*((N-1)/N): 2*pi/N: pi]';
N = 2*N-1;
w2 = [-pi*((N-1)/N): 2*pi/N: pi]';

% FFT
H = fftshift(fft(h));
Y = fftshift(fft(y));
Y_conv = fftshift(fft(conv(h,y)));

plot(w1,abs(Y.*H'));
hold on;
plot(w2,abs(Y_conv),'r');
hold off;

close all;

addpath('../../../../../EPO-4 Personal/repo/src/UBERGRAPH/');

x = {w1/2/pi};
y = {abs(Y.*H')};
LineStyle = {'-'};
LineMode = {'line'};
LineWidth = [1.5];
LineColor = [[1 0 0]];
MarkerStyle = {'none'};
MarkerFaceColor = [[1 0 0]];
MarkerEdgeColor = [[1 0 0]];
MarkerSize = [8];
legendText = {'|X(\omega) \cdotH(\omega)|'};
makeLegend = 'yes';
legendLocation = 'northEast';
logX = 0;

XTicks = 'auto';
YTicks = 'auto';
outputPath = 'output/ass-1-report-7-multiplication'; % 'off' to disable outputting
graphTitle = 'The convolution property';
yLabel = '|Y(\omega)|';
xLabel = 'Normalized frequency';
xLim = 'auto';
yLim = 'auto';

uber_graph;

x = {w2/2/pi};
y = {abs(Y_conv)};
LineStyle = {'-'};
LineMode = {'line'};
LineWidth = [1.5];
LineColor = [[1 0 0]];
MarkerStyle = {'none'};
MarkerFaceColor = [[1 0 0]];
MarkerEdgeColor = [[1 0 0]];
MarkerSize = [8];
legendText = {'|FFT[x(t) \ast h(t)]|'};
makeLegend = 'yes';
legendLocation = 'northEast';
logX = 0;

XTicks = 'auto';
YTicks = 'auto';
outputPath = 'output/ass-1-report-7-convolution'; % 'off' to disable outputting
graphTitle = 'The convolution property';
yLabel = '|Y(\omega)|';
xLabel = 'Normalized frequency';
xLim = 'auto';
yLim = 'auto';

uber_graph;
