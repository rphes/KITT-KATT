function [h, T] = est_matched_fast(x, y, L)
    %% Check input
    if size(x,1) > 1
        x = x';
        
        if size(x,1) > 1
            error('Only vectors are allowed.');
        end
    end
    
    if size(y,1) > 1
        y = y';
        
        if size(y,1) > 1
            error('Only vectors are allowed.');
        end
    end

    %% Init
    start = tic;
    N_x = length(x);
    N_y = L+N_x-1;

    %% Pad inserted
    % Size y
    diff = length(y)-N_y;

    if diff < 0
        y = [y zeros(1,-diff)];
    elseif diff > 0
        y = y(1:N_y);
    end
    
    %% Fasttoep inserted
    % Reverse and prefix zeros
    x_toep = flip([zeros(1,L-1) flip(x)]);
    
    % Calculate toeplitz matrix
    T = tril(toeplitz(x_toep));
    
    % Cut
    T = T(:,1:(size(T,2)-length(x)+1));
  
    %% Matched estimation
    h = y*T/norm(x)^2;
    
    %% Report
    time = toc(start);
    display(['Toeplitz: ' num2str(size(T,1)) 'x' num2str(size(T,2))]);
    display(['Time: ' num2str(round(100*time)/100)]);
end

