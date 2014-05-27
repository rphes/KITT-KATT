init;

L = 10;
subplot_y = 2;
subplot_x = ceil(length(seqs_desc)/subplot_y);

close all;
for i=1:length(seqs_desc)
    display(['Sequence: ' seqs_desc{i}]);
    display '-------------------------';

    % Generate data
    h_data = {};
    len = 0;
    for j = 1:length(methods_desc)
        h_data{j} = methods{j}(x{i},y{i}, L);

        if len < length(h_data{j})
            len = length(h_data{j});
        end
    end

    h = [];
    for j = 1:length(h_data)
        h = [h pad(h_data{j}, len)'];
    end

    % Plot
    figure(1);
    subplot(subplot_y,subplot_x,i);
    stem(h);
    xlabel 'n';
    ylabel 'Amplitude';
    title(['Channel estimation (' seqs_desc{i} ')']);
    xlabel 'n';
    ylabel 'Amplitude';
    legend(methods_desc);

    % Error per method
    h_err = [];
    for j = 1:length(methods)
        err = h(:,j) - pad(h_channel, length(h(:,j)))';
        h_err = [h_err err];
        err_biased = norm(err,2);
        
        % Unbiased error
        h_act = pad(h_channel, length(h(:,j)))'; % Actual
        h_h = h(:,j); % Estimation
        scale = h_h*h_act'/(h_h'*h_h); % Scale
        err_unbiased = norm(scale*h_h-h_act,2);
        
        display([methods_desc{j}...
            ' unbiased error: ' num2str(round(err_biased*100)/100)...
            ' (' num2str(round(err_unbiased*100)/100) ' unbiased)']);
    end
   
    figure(2);
    subplot(subplot_y,subplot_x,i);
    stem(h_err);
    xlabel 'n';
    ylabel 'Amplitude';
    title(['Channel estimation error (' seqs_desc{i} ')']);
    xlabel 'n';
    ylabel 'Amplitude';
    legend(methods_desc);

    % Autocorrelation
    Rx = conv(x{i},flip(x{i}))';
    t = ( (1-length(x{i})):1:(length(x{i})-1) )';
    
    figure(3);
    subplot(subplot_y,subplot_x,i);
    stem(t,Rx);
    xlabel 'n';
    ylabel 'Amplitude';
    title(['Autocorrelation (' seqs_desc{i} ')']);
    xlabel 'n';
    ylabel 'Amplitude';
    
    % Check matched filter
    h_match = h(:,2);
    t_pre = length(x{i})-1;
    h_match_raw = conv(Rx,h_channel);
    % Don't forget the scaling factor of the matched filter!
    h_match_clean = h_match_raw((t_pre+1):length(h_match_raw))/norm(x{i})^2;
    h_match_padded = pad(h_match_clean', length(h_match))';
    err = norm(h_match_padded-h_match,2);
    display(['Matched filter difference check: ' num2str(round(err*100)/100)]);

    display ' ';
end

display '[Done]';
