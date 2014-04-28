function [l] = get_length( Z_in, Z_0, Z_L, f, e_r, max)
% Calculate the possible lengths of a transmission line within a given range for a given input impedance, using the given characteristics

c_0 = 3e8;
lambda = c_0 / (f * sqrt(e_r));
beta = 2*pi/lambda';

l_0 = real(1/beta * atan((Z_0*(Z_L-Z_in))/(1i*(Z_L*Z_in-Z_0^2))));
num_k = floor((max - l_0) / (pi/beta));

if l_0 > 0
	k_0 = 0;
else
	k_0 = 1;
	num_k = num_k-1;
end

l = ones(1,num_k-k_0)*l_0;
k = k_0:(num_k-1);

l = l + k*(pi/beta);
end

