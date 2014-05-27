function [loc] = localize_man(R, mics, svd_th)
    N = size(R,1);
    Np = (N*N-N)/2;
    pairs = zeros(Np,2);
    D = size(mics,2);

    ii = 1;
    for i = 1:N
        for j = (i+1):N
            pairs(ii,1) = i;
            pairs(ii,2) = j;
            ii = ii+1;
        end
    end

    % Generate A and B
    A = zeros(Np,2+N-1);
    for i = 1:Np
        i1 = pairs(i,1);
        i2 = pairs(i,2);

        A(i,1:D) = 2*(mics(i2,:) - mics(i1,:));
        A(i,D+(i2-1)) = -2*R(i2,i1);
    end

    b = zeros(Np,1);
    for i = 1:Np
        i1 = pairs(i,1);
        i2 = pairs(i,2);

        b(i) = R(i1,i2)^2-norm(mics(i1,:),2)^2+norm(mics(i2,:),2)^2;
    end

    % Least squares approximation
    loc = svd_filter(A'*A, svd_th, 1)*A'*b;
    loc = loc(1:D)';
end
