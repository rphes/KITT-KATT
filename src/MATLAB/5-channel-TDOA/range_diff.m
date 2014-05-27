function [R] = range_diff(data, M, settings)
    % Settings:
    % settings.Fs = <sample frequency>
    % settings.speed_sound = <speed of sound>
    % settings.peak_threshold = <peak detection threshold>
    % settings.trim_threshold = <data trimming threshold>
    % settings.trim_padding = <data trimming padding>

    data_trimmed = trim_data(data, settings.trim_threshold, settings.trim_padding);
    N = size(data_trimmed,2);
    
    d = [];
    % Recover channel impulse responses
    for i = 1:N
        [~, d(i)] = est_h(data_trimmed(:,i), M{i}, settings.Fs, settings.peak_threshold);
    end

    R = [];
    % Generate R matrix
    for i = 1:N
        for j = (i+1):N
            R(i,j) = (d(i)-d(j))*settings.speed_sound;
            R(j,i) = -R(i,j);
        end
    end
end