function [ACorrected] = SVDFilter(A, Threshold, DoInvert)
    % SVD correction
    [U,S,V] = svd(A);
    IndexMax = size(S,1);

    for Index = 1:size(S,1)
        if S(Index,Index) < Threshold
            IndexMax = Index-1;
            break;
        end
    end

    U = U(:,1:IndexMax);
    V = V(:,1:IndexMax);
    S = S(:,1:IndexMax);
    S = S(1:IndexMax,:);
    
    if DoInvert == 0
        ACorrected = U*S*V';
    else
        ACorrected = V*S^-1*U';
    end
end