function [x1 x2 x3 x4 y1 y2 y3 y4] = datagen (N,Nx,h,sigma)
%USAGE:
%Nx is the total length of the input vector x
%N is the length of nonzero samples in x3 and x4
%h is the channel
%sigma is the noise standard deviation N~N(0,sigma^2);
if (Nx<N)||(Nx<3)
    disp('Size of N or Nx is not correct');
    return
end
x1 = [1; -0.5; zeros(Nx-2,1)];
x2 = [1; -2; zeros(Nx-2,1)];
n = [0:N-1];omega=0.2;
x3 = [cos(omega*n)'; zeros(Nx-N,1)];
m = sign(randn(Nx,1));
x4 = m.*x3;

Ny=length(x1)+length(h)-1;
y1=conv(x1,h)+sigma*randn(Ny,1);
y2=conv(x2,h)+sigma*randn(Ny,1);
y3=conv(x3,h)+sigma*randn(Ny,1);
y4=conv(x4,h)+sigma*randn(Ny,1);
end