%% THIS IS MERELY A DEMONSTRATION!!!
function [data] = trim_data(data, padding)
    padding=0;
    start_time = tic();
    start_slow = find_start(data,7,5)
    toc(start_time);
    start_fast_time = tic();
    start_fast = find_start_fast(data,7,200)
    toc(start_fast_time);
    %tijdelike beunfix:
    if start_slow-padding <= 0
        data_slow = [zeros(padding-start_slow, size(data,2)); data];
    else
        data_slow = data((start_slow-padding):size(data,1),:);
    end
    subplot(2,1,1);
    plot(data_slow(1:1000))
    
    if start_fast-padding <= 0
        data_fast = [zeros(padding-start_fast, size(data,2)); data];
    else
        data_fast = data((start_fast-padding):size(data,1),:);
    end
    subplot(2,1,2);
    plot(data_fast(1:1000))
end