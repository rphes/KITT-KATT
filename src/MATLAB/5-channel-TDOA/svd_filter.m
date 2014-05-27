function [Acorr] = svd_filter(A, th, inv)
    % SVD correction
    [U,S,V] = svd(A);
    i_max = size(S,1);

    for i = 1:size(S,1)
        if S(i,i) < th
            i_max = i-1;
            break;
        end
    end

    U = U(:,1:i_max);
    V = V(:,1:i_max);
    S = S(:,1:i_max);
    S = S(1:i_max,:);
    
    if inv == 0
        Acorr = U*S*V';
    else
        Acorr = V*S^-1*U';
    end
end