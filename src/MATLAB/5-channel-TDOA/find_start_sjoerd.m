function [start] = find_start_sjoerd(data, threshold, interval_length)
    % The algorithm works as follows: create intervals and calculate the 
    % standard deviation for each interval. 
    % If the standard deviation of a particular interval std(i) is more than
    % threshold*std(i-1), the start has been found.
    % The interval length can also be specified
    % Recommended settings: threshold: 7, interval_length: 5

    % Number of samples in one interval
    start=0;
    start=length(data);
    for i = 1:(length(data)-interval_length)
        std_interval(i)=std(data(i:i+interval_length));
        mean_interval(i)=mean(std_interval(1:i-1));
        if (i~=1)&&(std_interval(i)/mean_interval(i)>threshold)
            start=ceil(i+interval_length/2);
            return            
        end
    end
    
end