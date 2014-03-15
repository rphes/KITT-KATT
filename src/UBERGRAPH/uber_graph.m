%% UBERGRAPH
% Features:
% - Nice looking graph
% - Multiple graphs
% - Export to PDF
% TODO:
% - Grid lines width and color
% - change '-1' value

%% Example

% Single graph

% x = [1 2 3 4 5];
% y = [1 2 4 5 5];
% LineStyle = '-';
% LineColor = [1 0 0];
% MarkerStyle = 'o';
% MarkerColor = [.75 .75 .75];
% legendText = {'line'};
% logX = 0;

% Multiple graphs

% x = [[1 2 3 4 5];[1 2 3 4 5]]
% y = [[1 2 3 4 5];[1 4 6.2 4 2]]
% LineStyle = ['-';'-']
% LineColor = [[1 0 0];[0 1 0]];
% MarkerStyle = ['o';'o'];
% MarkerColor = [[.75 .75 .75];[.75 .75 .75]];
% legendText = {'line1', 'line2'};
% logX = 0;

% Config

% XTicks = -10:1:10;
% YTicks = -10:1:10;
% outputPath = 'output/testGraph'; % '-1' to disable outputting
% graphTitle = 'title';
% yLabel = 'ylabel';
% xLabel = 'xlabel';
% xLim = '-1';
% yLim = [0 200];

%% Script    
% Size in inches
width = 5.5;
height = 3.5;

screenSize = get(0,'ScreenSize');

% Center figure
figure('Units', 'pixels',...
    'Position', [...
    (screenSize(3)-width*100)/2 ...
    (screenSize(4)-height*100)/2 ...
    width*100 height*100]);
hold on;

hData = zeros(size(x,1));

for i = 1:size(x,1)

%     if (size(x,2) > 1)
        xData = x(i,:);
        yData = y(i,:);
%     else
%         xData = x;
%         yData = y;
%     end
    
    hData(i) = line(xData, yData);

    % Esthetical line properties
    set(hData(i),...
        'LineStyle', LineStyle(i),...
        'Color', LineColor(i,:),...
        'LineWidth', 1.5,...
        'Marker', MarkerStyle(i),...
        'MarkerSize', 8,...
        'MarkerEdgeColor', [0 0 0],...
        'MarkerFaceColor', MarkerColor(i,:));
end

% Logaritmic view
if logX
    set(gca,...
        'xscale', 'log');
end

hTitle = title(graphTitle);
hXLabel = xlabel(xLabel);
hYLabel = ylabel(yLabel);

if (makelegend ~= 0)
    legend(legendText,...
        'Location',legendLocation);
end

% Esthetical label, legend and title properties
set(gca,...
    'FontName','Helvetica',...
    'FontSize', 11);
set([hXLabel, hYLabel],...
    'FontSize',11);
set(hTitle,...
    'FontSize',11,...
    'FontWeight','bold');

% Esthetical graph properties
set(gca,...
    'Box', 'off',...
    'TickDir', 'out',...
    'TickLength', [.02, .02],...
    'XMinorTick', 'on',...
    'YMinorTick', 'on',...
    'XGrid', 'on',...
    'YGrid', 'on',...
    'GridLineStyle', '-',...
    'MinorGridLineStyle', '-',...
    'XColor', [.3 .3 .3],...
    'YColor', [.3 .3 .3],...
    'LineWidth', 1);

% Ticks
if not (XTicks == -1)
    set(gca,...
        'XTick', XTicks);
end

if not (YTicks == -1)
    set(gca,...
        'YTick', YTicks);
end

% Limits
if not (xLim == -1)
    xlim(xLim);
end

if not (yLim == -1)
    ylim(yLim);
end

if not (outputPath == -1)
    % Preservation settings
    set(gcf,...
        'InvertHardcopy','on',...
        'PaperUnits','inches');

    paperSize = get(gcf, 'PaperSize');

    left = (paperSize(1) - width)/2;
    bottom = (paperSize(2) - height)/2;

    set(gcf,...
        'PaperPosition', [0  0 width height],...
        'PaperSize', [width height]);

    saveas(gcf, outputPath, 'pdf');
end
