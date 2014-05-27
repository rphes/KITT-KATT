% Works fine with data22!

% TODO:
% - Better peak detection, current algorithm takes too long

% Localization settings
smart_localization = 1;
smart_th = 0.05; % Threshold for smart
use_3d = 0;
svd_th = 0.05; % SVD threshold for regular localization

% Data
mics_3d = [
    0     0    0.38;
    0     2.9  0.38;
    2.9   2.9  0.38;
    2.9   0    0.38;
    -0.95 1.45 0.93
];

mics_2d = [
    0     0;
    0     2.9;
    2.9   2.9;
    2.9   0;
    -0.95 1.45
];

if use_3d
    mics = mics_3d;
else
    mics = mics_2d;
end


locs_should_be = [
    0     0;
    0     2.9;
    2.9   2.9;
    2.9   0;
    -0.95 1.45;
    1.45 1.45;
    1.45+1/sqrt(2) 1.45+1/sqrt(2)
];
    

locs = [];
locs_custom = [];
D = [];
R = {};

for i = 1:7
    start = tic;
    data = RXXr(i,:,:);
    data = reshape(data,size(data,2),size(data,3));

    settings = struct;
    settings.Fs = 44100;
    settings.peak_threshold = .5;
    settings.trim_threshold = .85;
    settings.trim_padding = 750;
    settings.speed_sound = 330;

    % Determine range difference matrix
    R{i} = range_diff(data, M, settings);
    
    % Localization
    if smart_localization
        locs = [locs;localize_smart(R{i}, mics, smart_th)];
    else
        locs = [locs;localize_man(R{i}, mics, svd_th)];
    end
    display(['Localization ' num2str(i) ' took ' num2str(round(1000*toc(start))) ' ms']);
    
    % Fill D matrix
    if i <= 5
        for j = 1:5
            D(i,j) = R{i}(i,j);
            D(j,i) = R{i}(j,i);
        end
    end
end

% MDS microphone localization and beacon localization
mics_determined = mds_mic_localization(D);

for i = 1:length(R)
    locs_custom = [locs_custom;localize_man(R{i}, mics_determined, svd_th)];
end

% Distance between 6 and 7
distance_between_6_and_7 = norm(locs(6,:)-locs(7,:))

% Error
loc_error = locs(:,1:2) - locs_should_be(:,1:2);
loc_error = sqrt(loc_error(:,1).^2+loc_error(:,2).^2);
loc_error_mean_cm = mean(loc_error)*100
loc_error_std_cm = std(loc_error)*100

mds_error = mics_determined-mics;
mds_error = sqrt(mds_error(:,1).^2+mds_error(:,2).^2);
mds_error_mean_cm = mean(mds_error)*100
mds_error_std_cm = std(mds_error)*100

% Plot
% dot_size = 8;
% plot(mics_2d(:,1),mics_2d(:,2),'or','MarkerFaceColor','red','MarkerSize',dot_size);
% hold on;
% plot(mics_determined(:,1),mics_determined(:,2),'og','MarkerFaceColor','green','MarkerSize',dot_size);
% plot(locs(:,1),locs(:,2),'o','MarkerFaceColor','blue','MarkerSize',dot_size);
% plot(locs_custom(:,1),locs_custom(:,2),'o','MarkerFaceColor','black','MarkerSize',dot_size);
% grid on;
% hold off;
% xlabel 'x (m)';
% ylabel 'y (m)';
% ylim([-1 3]);
% title 'Field';
% legend({
%     'Microphone locations',
%     'Determined microphone locations',
%     'Determined beacon locations',
%     'Determined beacon locations by determined microphone locations'
% },'Location','SouthEast');

% UBERGRAPH plots
addpath('../../../../../../EPO-4 Personal/repo/src/UBERGRAPH/');

% MDS localization
x = {mics_2d(:,1),mics_determined(:,1)};
y = {mics_2d(:,2),mics_determined(:,2)};
LineStyle = {'none','none'};
LineMode = {'stem','stem'};
LineWidth = [1.5;1.5];
LineColor = [[1 0 0];[0 1 0]];
MarkerStyle = {'o','o'};
MarkerFaceColor = [[1 0 0];[0 1 0]];
MarkerEdgeColor = [[1 0 0];[0 1 0]];
MarkerSize = [8;8];
legendText = {'Microphone locations','Determined microphone locations'};
makeLegend = 'yes';
legendLocation = 'southEast';
logX = 0;

XTicks = 'auto';
YTicks = 'auto';
outputPath = 'output/ass-2-report-9'; % 'off' to disable outputting
graphTitle = 'MDS microphone localization';
yLabel = 'y (m)';
xLabel = 'x (m)';
xLim = 'auto';
yLim = [-1 3];

uber_graph;

% Localization
x = {locs_should_be(:,1),locs(:,1),locs_custom(:,1)};
y = {locs_should_be(:,2),locs(:,2),locs_custom(:,2)};
LineStyle = {'none','none','none'};
LineMode = {'stem','stem','stem'};
LineWidth = [1.5;1.5;1.5];
LineColor = [[1 0 0];[0 1 0];[0 0 1]];
MarkerStyle = {'o','o','o'};
MarkerFaceColor = [[1 0 0];[0 1 0];[0 0 1]];
MarkerEdgeColor = [[1 0 0];[0 1 0];[0 0 1]];
MarkerSize = [8;8;8];
legendText = {'Actual locations','Localizations','Localizations using determined microphone locations'};
makeLegend = 'yes';
legendLocation = 'southEast';
logX = 0;

XTicks = 'auto';
YTicks = 'auto';
outputPath = 'output/ass-2-report-6'; % 'off' to disable outputting
graphTitle = 'Localization';
yLabel = 'y (m)';
xLabel = 'x (m)';
xLim = 'auto';
yLim = [-1.2 3];

uber_graph;