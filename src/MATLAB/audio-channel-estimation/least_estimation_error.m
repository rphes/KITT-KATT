init;

L = 1:10;
subplot_y = 2;
subplot_x = ceil(length(seqs_desc)/subplot_y);

close all;

for i=1:length(seqs_desc)
    err = zeros(length(methods),length(L));
    
    for L_i=1:length(L)
        % Generate data
        h_data = {};
        len = 0;
        for j = 1:length(methods_desc)
            h_data{j} = methods{j}(x{i},y{i}, L(L_i));

            if len < length(h_data{j})
                len = length(h_data{j});
            end
        end

        % Error per method
        for j = 1:length(methods)
            if length(h_channel) < length(h_data{j})
                h_ch = pad(h_channel, length(h_data{j}))';
                h_est = h_data{j}';
            else
                h_est = pad(h_data{j}, length(h_channel))';
                h_ch = h_channel';
            end

            scale = 1;
            if j == 2 % Matched filter!
                scale = h_est'*h_ch/(h_est'*h_est);
            end

            err(j,L_i) = norm(h_est*scale-h_ch,2);
        end
    end
    
    L_mat = [];
    for j=1:length(methods)
        L_mat = [L_mat;L];
    end
    
%     figure(1);
%     subplot(subplot_y,subplot_x,i);
%     stem(L_mat',err','fill','LineStyle','none');
%     xlabel 'L';
%     ylabel 'Error';
%     title(['Channel estimation error (' seqs_desc{i} ')']);
%     grid on;
%     legend(methods_desc);

        addpath('../../../../../../EPO-4 Personal/repo/src/UBERGRAPH/');

        close all;

        xp = x;
        yp = y;
        ip = i;
        jp = j;
        
        x = {L_mat(1,:),L_mat(2,:)};
        y = {err(1,:),err(2,:)};
        LineStyle = {'-','-'};
        LineMode = {'stem','stem'};
        LineWidth = [1.5;1.5];
        LineColor = [[1 0 0];[0 1 0]];
        MarkerStyle = {'o','o'};
        MarkerFaceColor = [[1 0 0];[0 1 0]];
        MarkerEdgeColor = [[1 0 0];[0 1 0]];
        MarkerSize = [8;8];
        legendText = methods_desc;
        makeLegend = 'yes';
        legendLocation = 'northEast';
        logX = 0;

        XTicks = 'auto';
        YTicks = 'auto';
        outputPath = ['output/ass-1-report-9-' seqs_desc{i}]; % 'off' to disable outputting
        graphTitle = ['Channel estimation error (' seqs_desc{i} ')'];
        yLabel = 'Error';
        xLabel = 'Length of estimated impulse response';
        xLim = 'auto';
        yLim = 'auto';

        uber_graph;
        
        x = xp;
        y = yp;
        i = ip;
        j = jp;
end

display '[Done]';
