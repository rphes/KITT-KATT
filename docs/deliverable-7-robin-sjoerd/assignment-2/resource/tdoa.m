function [x] = tdoa(R,X)
% Generate pairs
N = size(R,1);
Np = (N*N-N)/2;
pairs = zeros(Np,2);
D = size(X,2);

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
    x1 = X(i1,:);
    i2 = pairs(i,2);
    x2 = X(i2,:);
    
    A(i,1:D) = 2*(x2-x1)';
    A(i,(D-1)+i2) = -2*R(i1,i2);
end

B = zeros(Np,1);
for i = 1:Np
    i1 = pairs(i,1);
    x1 = X(i1,:);
    i2 = pairs(i,2);
    x2 = X(i2,:);
    
    B(i) = R(i1,i2)^2-norm(x1,2)^2+norm(x2,2)^2
end

% Least squares approximation
x = (A'*A)^-1*A'*B;
end