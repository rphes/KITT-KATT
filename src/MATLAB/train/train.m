load train

addpath('../../../../../EPO-4 Personal/repo/src/UBERGRAPH/');

close all;

t = (0:(length(y)-1))/Fs;

x = {t};
y = {y};
LineStyle = {'-'};
LineMode = {'line'};
LineWidth = [1.5];
LineColor = [[1 0 0]];
MarkerStyle = {'none'};
MarkerFaceColor = [[0 0 0]];
MarkerEdgeColor = [[0 0 0]];
MarkerSize = [8];
legendText = {''};
makeLegend = 'no';
legendLocation = 'northEast';
logX = 0;

XTicks = 'auto';
YTicks = 'auto';
outputPath = 'output/ass-1-report-3'; % 'off' to disable outputting
graphTitle = 'Time domain train signal';
yLabel = 'Amplitude';
xLabel = 'Time (s)';
xLim = 'auto';
yLim = 'auto';

uber_graph;