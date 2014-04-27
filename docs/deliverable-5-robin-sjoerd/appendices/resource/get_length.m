function [l] = get_length( Z_in, Z_0, Z_L, f, e_r, max)
%Calculate the possible lengths of a transmission line, using various characteristics

c_0 = 3e8;
lambda = c_0 / (f * sqrt(e_r));
beta = 2*pi/lambda';

l_0 = real(1/beta * atan((Z_0*(Z_L-Z_in))/(1i*(Z_L*Z_in-Z_0^2))));

num_k = floor((max - l_0) / (pi/beta));

l = ones(1,num_k)*l_0;
k = 0:(num_k-1);

l = l + k*(pi/beta);
end

