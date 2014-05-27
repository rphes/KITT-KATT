function [data] = trim_data(data, level, padding)
    start = [];
    
    % Find starts
    for i = 1:size(data,2)
        % Maximum signal level
        max_sig = max(data(:,i));
        
        for j = 1:length(data(:,i))
            if data(j,i) >= level*max_sig
                start(i) = j;
                break
            end
        end
    end
    
    start = min(start);
    
    if start-padding <= 0
        data = [zeros(padding-start, size(data,2)); data];
    else
        data = data((start-padding):size(data,1),:);
    end
end