function [result] = trim_fast_5chan(data, num_ints)
    % Usage:
    % Input: data to be trimmed, num_ints is the amount
    %        of interval the series is divided into (more means more
    %        processing time required).
    % Output: trimmed data series using fast peak alg
    % Extra: uncomment the lines containing tic() and toc() to enable
    % timing. This can be useful for debugging, e.g. checking if the alg
    % doesn't spend too much time finding the start. Good initial values
    % for debugging are num_ints = 100
    
    %input sanitation
    if size(data,2)>size(data,1)
        data=data';
    end
    
    start_fast_time = tic();
    for i=1:size(data,2)
        start(i) = find_start_fast(data,7,num_ints);
    end
    start = min(start);
    toc(start_fast_time);
    % this may be optimized 
    
    result = data(start:start+10000,:);
end