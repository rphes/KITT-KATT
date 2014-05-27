function [T] = tdoa(x, M, Fs)
    % TDOA matrix generation
    %
    % Usage:
    % [
    %     <TDOA matrix>
    % ] = tdoa(
    %     <N received signals of length N_x (N_x x N matrix)>,
    %     <deconv matrix>,
    %     <sample frequency>
    % )
    
    N = size(x,2);
    delays = zeros(1,N);
    
    % Estimate delays
    for i = 1:N
        [~, delay] = est_h(x(:,i), M, Fs, 0.8);
        delays(i) = delay;
    end
    
    T = zeros(N,N);
    for i = 1:N
        for j = 1:N
            T(i,j) = delays(i)-delays(j);
        end
    end
end