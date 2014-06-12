function [Location] = Localize(RangeDiffMatrix, Mics)
    % Check for error
    if isempty(RangeDiffMatrix)
        Location = [];
        return
    end

    N = size(RangeDiffMatrix,1);
    Np = (N*N-N)/2;
    Pairs = zeros(Np,2);
    D = size(Mics,2);

    % Generate pairs
    Index = 1;
    for i = 1:N
        for j = (i+1):N
            Pairs(Index,1) = i;
            Pairs(Index,2) = j;
            Index = Index+1;
        end
    end

    % Generate A and b
    A = zeros(Np,2+N-1);
    for i = 1:Np
        i1 = Pairs(i,1);
        i2 = Pairs(i,2);

        A(i,1:D) = 2*(Mics(i2,:) - Mics(i1,:));
        A(i,D+(i2-1)) = -2*RangeDiffMatrix(i2,i1);
    end

    b = zeros(Np,1);
    for i = 1:Np
        i1 = Pairs(i,1);
        i2 = Pairs(i,2);

        b(i) = RangeDiffMatrix(i1,i2)^2-norm(Mics(i1,:),2)^2+norm(Mics(i2,:),2)^2;
    end
    
    % Least squares approximation
    Location = (A'*A)^-1*A'*b;
    Location = Location(1:2)';
end
