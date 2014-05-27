function [h, delay] = est_h(x, M, Fs, peak_level)
    % Estimation of impulse response
    %
    % Usage:
    % [
    %     <impulse response>
    % ] = est_h(
    %     <received signal>,
    %     <deconv matrix>,
    %     <sample frequency>,
    %     <peak level>
    % )
    
    if size(x,2) > 1
        x = x';
    end    
    
    N_y = size(M,2);
    diff = N_y-length(x);
    
    if diff > 0
        x = [x;zeros(diff,1)];
    elseif diff < 0
        x = x(1:N_y);
    end
    
    h = M*x;
    
    % Detect peak
    max_h = max(h);
    
    for i = 1:length(h)
        if h(i) >= peak_level*max_h
            delay = i/Fs;
            break
        end
    end
end