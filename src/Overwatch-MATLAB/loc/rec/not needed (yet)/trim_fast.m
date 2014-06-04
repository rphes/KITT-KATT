function [data] = trim_fast(data, padding, num_ints)
    % Usage:
    % Input: data to be trimmed, number of zeros that should be padded
    %        BEFORE the start of the trimmed series, num_ints is the amount
    %        of interval the series is divided into (more means more
    %        processing time required).
    % Output: trimmed data series using fast peak alg
    % Extra: uncomment the lines containing tic() and toc() to enable
    % timing. This can be useful for debugging, e.g. checking if the alg
    % doesn't spend too much time finding the start. Good initial values
    % for debugging are 
%     start_fast_time = tic();
    start = find_start_fast(data,7,num_ints)
%     toc(start_fast_time);
    % this may be optimized 
    
    data = [zeros(padding, size(data,2)); data(start:start+3000)];
end