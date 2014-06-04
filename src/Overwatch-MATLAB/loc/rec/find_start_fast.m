function [start] = find_start_fast(data, threshold, number_of_intervals)
    % The algorithm works as follows: create intervals and calculate the 
    % standard deviation for each interval. 
    % If the standard deviation of a particular interval std(i) is more than
    % threshold*std(i-1), the start has been found.
    % The interval length can also be specified
    % Recommended settings: threshold: 7, interval_length: >100 (depending
    % on the number of samples in the data)
    std_interval=[];
    mean_interval=[];
    start=0;
    step_size=floor(length(data)/number_of_intervals)-1;
    for i=1:number_of_intervals
        interval_start=1+(i-1)*step_size;
        std_interval(i)=std(data(interval_start:interval_start+step_size));
        mean_interval(i)=mean(std_interval(1:i-1));
        if (i~=1)&&(std_interval(i)/mean_interval(i)>threshold)
            start=interval_start;
            return
        end
    end
    if (start == 0)
        start=1;
    end
end