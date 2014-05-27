init;

N = length(seqs_desc);

display 'Note: autocorrelation not included';
close all;
for i=1:N
    cc = 0;
    
    for j=1:N        
        x_seq = x{i};
        y_seq = x{j};
        
        % Calculate correlation
        C = conv(x_seq,flip(y_seq))';
        t = (1-length(x_seq)):1:(length(y_seq)-1);
        
        if i ~= j
            cc = cc+norm(C,2);
        end

%         subplot(N,N,(i-1)*N+j);
%         stem(t,C);
%         xlabel 'n';
%         ylabel 'Amplitude';
%         title(['Crosscorrelation (' seqs_desc{i} ' - ' seqs_desc{j} ')']);
%         xlabel 'n';
%         ylabel 'Amplitude';
        
        addpath('../../../../../../EPO-4 Personal/repo/src/UBERGRAPH/');

        close all;

        xp = x;
        yp = y;
        ip = i;
        jp = j;
        
        x = {t};
        y = {C};
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
        outputPath = ['output_cross/ass-1-report-8-' seqs_desc{i} '-' seqs_desc{j}]; % 'off' to disable outputting
        
        if i ~= j
            graphTitle = ['Crosscorrelation (' seqs_desc{i} ' - ' seqs_desc{j} ')'];
        else
            graphTitle = ['Autocorrelation (' seqs_desc{i} ')'];
        end
        
        yLabel = 'Amplitude';
        xLabel = 'n';
        xLim = 'auto';
        yLim = 'auto';

        uber_graph;
        
        x = xp;
        y = yp;
        i = ip;
        j = jp;
    end
    
    display(['Total correlation for ' seqs_desc{i} ': ' num2str(round(cc*100)/100)]);
end

display '[Done]';
