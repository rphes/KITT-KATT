function [start] = find_start(data, threshold)
    %{a    
	confidence = 2;
    
    % Confidence
    % It cannot be A% of the peaks. The peak we want to
    % find is less than <threshold>*A% of the peaks which
    % remain.
    
    % 1: A = 65
    % 2: A = 95
    % 3: A = 99

    % Filter
    peak_filter = std(data)*confidence;

    % Find all peaks
    peaks_ind = [];
    peaks_amp = [];
    
    for i = 2:(length(data)-1)
        if (data(i-1) < data(i)) && (data(i) > data(i+1)) && (data(i) > peak_filter)
            peaks_ind = [peaks_ind i];
            peaks_amp = [peaks_amp data(i)];
        end
    end
    
    peak_std = std(peaks_amp);
    min_level = confidence*peak_std*threshold;
    
    for i = 1:length(peaks_amp)
        if peaks_amp(i) >= min_level
            start = peaks_ind(i);
            break
        end
    end
    start
    %}

    %{
    % OLD ALGORITHM
    max_level = max(data);
    for start = 1:length(data)
        if data(start) > max_level*threshold
            break
        end
    end
    %}
end