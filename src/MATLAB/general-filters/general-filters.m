N = 21;
h1 = filter(1,[1 0.95],[1 zeros(1,N-1)]);
h2 = filter(1,[1 -0.95],[1 zeros(1,N-1)]);
t = 0:(N-1);
f = [-pi*((N-1)/N): 2*pi/N: pi]/(2*pi);
H1 = fftshift(fft(h1));
H2 = fftshift(fft(h2));

addpath('../../../../../EPO-4 Personal/repo/src/UBERGRAPH/');

close all;

x = {t};
y = {h1};
LineStyle = {'-'};
LineMode = {'stem'};
LineWidth = [1.5];
LineColor = [[1 0 0]];
MarkerStyle = {'o'};
MarkerFaceColor = [[1 0 0]];
MarkerEdgeColor = [[1 0 0]];
MarkerSize = [8];
legendText = {''};
makeLegend = 'no';
legendLocation = 'northEast';
logX = 0;

XTicks = 'auto';
YTicks = 'auto';
outputPath = 'output/ass-1-report-2-a-positive'; % 'off' to disable outputting
graphTitle = 'Filter impulse response for a = 0.95';
yLabel = 'Amplitude';
xLabel = 'Time';
xLim = 'auto';
yLim = 'auto';

uber_graph;

x = {t};
y = {h2};
LineStyle = {'-'};
LineMode = {'stem'};
LineWidth = [1.5];
LineColor = [[1 0 0]];
MarkerStyle = {'o'};
MarkerFaceColor = [[1 0 0]];
MarkerEdgeColor = [[1 0 0]];
MarkerSize = [8];
legendText = {''};
makeLegend = 'no';
legendLocation = 'northEast';
logX = 0;

XTicks = 'auto';
YTicks = 'auto';
outputPath = 'output/ass-1-report-2-a-negative'; % 'off' to disable outputting
graphTitle = 'Filter impulse response for a = -0.95';
yLabel = 'Amplitude';
xLabel = 'Time';
xLim = 'auto';
yLim = 'auto';

uber_graph;

x = {f};
y = {abs(H1)};
LineStyle = {'-'};
LineMode = {'stem'};
LineWidth = [1.5];
LineColor = [[1 0 0]];
MarkerStyle = {'o'};
MarkerFaceColor = [[1 0 0]];
MarkerEdgeColor = [[1 0 0]];
MarkerSize = [8];
legendText = {''};
makeLegend = 'no';
legendLocation = 'northEast';
logX = 0;

XTicks = 'auto';
YTicks = 'auto';
outputPath = 'output/ass-1-report-2-a-positive-spectrum'; % 'off' to disable outputting
graphTitle = 'Transfer function for a = 0.95';
yLabel = '|H(\omega)|';
xLabel = 'Normalized frequency';
xLim = 'auto';
yLim = 'auto';

uber_graph;

x = {f};
y = {abs(H2)};
LineStyle = {'-'};
LineMode = {'stem'};
LineWidth = [1.5];
LineColor = [[1 0 0]];
MarkerStyle = {'o'};
MarkerFaceColor = [[1 0 0]];
MarkerEdgeColor = [[1 0 0]];
MarkerSize = [8];
legendText = {''};
makeLegend = 'no';
legendLocation = 'northEast';
logX = 0;

XTicks = 'auto';
YTicks = 'auto';
outputPath = 'output/ass-1-report-2-a-negative-spectrum'; % 'off' to disable outputting
graphTitle = 'Transfer function for a = -0.95';
yLabel = '|H(\omega)|';
xLabel = 'Normalized frequency';
xLim = 'auto';
yLim = 'auto';

uber_graph;