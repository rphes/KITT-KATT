function [h] = est_matched(x, y, L)
    N_x = length(x);
    N_y = L+N_x-1;

    x = flip(x);
    y = pad(y, N_y);
    
    % Build Toeplitz matrix
    A = zeros(N_y,L);
    for i = 1:N_y
        A(i,i:(i+length(x)-1)) = x;
    end

    % Reshape and finish
    A(:,1:(length(x)-1)) = [];
    A(:,(L+1):size(A,2)) = [];

    if size(A,1) > N_y
        A((N_y+1):size(A,1),:) = [];
    elseif size(A,1) < N_y
        A = [A;zeros(N_y-size(A,1),size(A,2))];
    end
  
    % Matched estimation
    h = y*A/norm(x)^2;
end

