function [T] = fasttoep(x, L)
    % Reverse and prefix zeros
    x_toep = flip([zeros(1,L-1) flip(x)]);
    
    % Calculate toeplitz matrix
    T = tril(toeplitz(x_toep));
    
    % Cut
    T = T(:,1:(size(T,2)-length(x)+1));
end