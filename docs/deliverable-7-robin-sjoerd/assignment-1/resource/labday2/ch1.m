function [channel_estimate] = ch1(x, y, L_hat)
%USAGE
%creates channel estimate by inversion
%input x and y vector 
%input L_hat:
%   - specifies L 
%       or
%   - can be set to 0 to use default length for L: 
%       L = length(y)-length(x)+1
if L_hat==0
    L = length(y)-length(x)+1;
else
    L = L_hat;
end

X=toep(x,length(y),L);
channel_estimate = inv(X'*X)*X'*y;

%% plot the channel estimate
figure
plot_channel_estimate(channel_estimate,'n','$$\hat{h}$$[n]','Recovered channel estimate using time domain inversion');
end