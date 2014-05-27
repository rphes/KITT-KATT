function [start] = find_start_wrapper(data, threshold)
    %wrapper function for find_start
    %select mode:
    %mode 1 Wessel's find_start algorithm
    %mode 2 Sjoerd's find_start algorithm
    
    find_start_mode=2;
    if find_start_mode == 1
        start = find_start(data,threshold);
    elseif find_start_mode == 2
        threshold_sjoerd = 7;
        interval_length=5;
        start = find_start_sjoerd(data,threshold_sjoerd,interval_length);
    end
end