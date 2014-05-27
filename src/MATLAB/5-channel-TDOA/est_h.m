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
    
    % Find delay
    delay = find_start_wrapper(h, peak_level)/Fs;
end