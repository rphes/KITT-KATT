function [h, T] = est_project_fast(x, y, L, th)
    %% Check input
    if size(x,1) > 1
        x = x';
    end
    
    if size(y,1) > 1
        y = y';
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
  
    %% Matched estimation without correction
    h = y*T;
    
    %% Calculate correction
    [U,S,V] = svd(T'*T);
    i_max = size(S,1);
    
    for i = 1:size(S,1)
        if S(i,i) < th
            i_max = i-1;
            break;
        end
    end
    
    % Cut matrices
    U = U(:,1:i_max);
    V = V(:,1:i_max);
    S = S(:,1:i_max);
    S = S(1:i_max,:);
    
    corr = V*S^-1*U';
    h = h*corr;
    
    %% Report
    time = toc(start);
    display(['Toeplitz: ' num2str(size(T,1)) 'x' num2str(size(T,2))]);
    display(['Time: ' num2str(round(100*time)/100)]);
end

