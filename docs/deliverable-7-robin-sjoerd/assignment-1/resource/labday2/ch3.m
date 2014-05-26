function [channel_estimate] = ch3(x, y, L_hat)
%USAGE
%creates channel estimate by frequency domain deconvolution
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
Y=fft(y);
X=fft([x; zeros(length(y)-length(x),1)]);
size(Y)
size(X)
H=Y./X;
h=ifft(H);
channel_estimate=h(1:L);

%% plot the channel estimate
figure
plot_channel_estimate(channel_estimate(:,1),'n','$$\hat{h}$$[n]','Recovered channel estimate using frequency domain deconvolution');
end