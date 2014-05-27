%% General settings
noise_cm = 0:0.01:3;

%% Settings
dimensions = 2;

%% Process
% Data
mics = [
    0     0    0.38;
    0     2.9  0.38;
    2.9   2.9  0.38;
    2.9   0    0.38
    -0.95 1.45 0.93
];

% Calculate distance matrix
D_an = zeros(size(mics,1),size(mics,1));
for i = 1:size(mics,1)
    for j = (i+1):size(mics,1)
        D_an(i,j) = norm(mics(i,1:dimensions)-mics(j,1:dimensions));
        D_an(j,i) = -D_an(i,j);
    end
end

error_mean = [];
error_std = [];

for n = 1:length(noise_cm)
    noise = noise_cm(n)*1e-2;
    locs = [];
    locs_act = [];
    N = 50;

    for i = 1:N
        % Add noise
        D = D_an;
        for i = 1:size(mics,1)
            for j = (i+1):size(mics,1)
                D(i,j) = D(i,j) + randn(1,1)*noise;
                D(j,i) = -D(i,j);
            end
        end

        % Localization
        locs = [mds_mic_localization(D); locs];
        locs_act = [mics(:,1:dimensions); locs_act];
    end
    
    % Error analysis
    error = locs-locs_act;
    error = sqrt(error(:,1).^2+error(:,2).^2);
    error_mean = [error_mean mean(error)];
    error_std = [error_std std(error)];
end

% Ubergraph plot
addpath('../../../../../../EPO-4 Personal/repo/src/UBERGRAPH/');

% Mean
x = noise_cm;
y = error_mean*100;

A = [x' ones(length(x),1)];
b = y';
x_LS = (A'*A)^-1*A'*b;
rc = x_LS(1);
ofs = x_LS(2);
y_LS = rc*x+ofs;

display(['Mean error/noise standard deviation = ' num2str(round(1000*rc)/1000) ' cm']);

x = {x,x};
y = {y,y_LS};
LineStyle = {'-','-'};
LineMode = {'line','line'};
LineWidth = [1.5;1.5];
LineColor = [[1 0 0];[0 1 0]];
MarkerStyle = {'none','none'};
MarkerFaceColor = [[1 0 0];[0 1 0]];
MarkerEdgeColor = [[1 0 0];[0 1 0]];
MarkerSize = [8;8];
legendText = {'Estimation error mean','Least squares approximation'};
makeLegend = 'yes';
legendLocation = 'northEast';
logX = 0;

XTicks = 'auto';
YTicks = 'auto';
outputPath = 'output/ass-2-report-7-mean'; % 'off' to disable outputting
graphTitle = 'MDS microphone localization';
yLabel = 'Error mean (cm)';
xLabel = 'Noise standard deviation (cm)';
xLim = 'auto';
yLim = 'auto';

uber_graph;

% STD
x = noise_cm;
y = error_std*100;

A = [x' ones(length(x),1)];
b = y';
x_LS = (A'*A)^-1*A'*b;
rc = x_LS(1);
ofs = x_LS(2);
y_LS = rc*x+ofs;

display(['STD error/noise standard deviation = ' num2str(round(1000*rc)/1000) ' cm']);

x = {x,x};
y = {y,y_LS};
LineStyle = {'-','-'};
LineMode = {'line','line'};
LineWidth = [1.5;1.5];
LineColor = [[1 0 0];[0 1 0]];
MarkerStyle = {'none','none'};
MarkerFaceColor = [[1 0 0];[0 1 0]];
MarkerEdgeColor = [[1 0 0];[0 1 0]];
MarkerSize = [8;8];
legendText = {'Estimation error STD','Least squares approximation'};
makeLegend = 'yes';
legendLocation = 'northEast';
logX = 0;

XTicks = 'auto';
YTicks = 'auto';
outputPath = 'output/ass-2-report-7-std'; % 'off' to disable outputting
graphTitle = 'MDS microphone localization';
yLabel = 'Error STD (cm)';
xLabel = 'Noise standard deviation (cm)';
xLim = 'auto';
yLim = 'auto';

uber_graph;
