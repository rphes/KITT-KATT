function [M, N_y] = deconv_matrix(x, L, th)
    % Calculate deconvolution matrix
    %
    % Usage:
    % [
    %     <matrix>,
    %     <length of received signal>
    % ] = deconv_matrix(
    %     <sent sequence>,
    %     <length of impulse response>,
    %     <SVD threshold>
    % )

    if size(x,1) > 1
        x = x';
    end

    start = tic;
    N_x = length(x);
    N_y = L+N_x-1;
    
    display 'Building Toeplitz matrix';
    % Build toeplitz matrix
    x_toep = flip([zeros(1,L-1) flip(x)]);
    T = tril(toeplitz(x_toep));
    T = T(:,1:(size(T,2)-length(x)+1));
    
    display 'SVD analysis and correction';
    M = (T*svd_filter(T'*T,th,1))';
%     % SVD correction
%     [U,S,V] = svd(T'*T);
%     i_max = size(S,1);
%     
%     for i = 1:size(S,1)
%         if S(i,i) < th
%             i_max = i-1;
%             break;
%         end
%     end
%     
%     U = U(:,1:i_max);
%     V = V(:,1:i_max);
%     S = S(:,1:i_max);
%     S = S(1:i_max,:);
%     
%     display 'Inversion and correction';
%     corr = V*S^-1*U';
%     M = (T*corr)';
    
    
    %% Report
    time = toc(start);
    display(['Time: ' num2str(round(100*time)/100)]);
end

