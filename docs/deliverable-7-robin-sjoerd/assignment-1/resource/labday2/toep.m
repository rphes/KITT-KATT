function X = toep(x0,N,L);
% Create a Toeplitz matrix X, size N * L, first column given by x0.
% Suppose x0 has N0 entries, then
% if L is not specified, take L = N - N0 + 1
% else create a circulant matrix
% (require N0 <= N)
%
% Usage: The (circular) convolution of x0 and y is given by X*y
%        The matched filter of x0 and y is given by X'*y
% (Both can be more efficiently computed using 'filter'.)

N0 = length(x0);
x0 = x0(:);		% ensure x0 is a column vector

if N0 > N, 
    error('Length of x0 should be at most equal to N');
end

if nargin < 3,
    % L not specified
    L = N - N0 + 1;
end

% at this point, L >= N - N0 + 1

X = zeros(N,L);
for ii = 1:N,
    for jj = 1:L,
	index = ii - jj;
	index = mod(index,N) + 1;		% index in [1,N]

	if index <= N0,
	    X(ii,jj) = x0(index);
	end
    end
end
