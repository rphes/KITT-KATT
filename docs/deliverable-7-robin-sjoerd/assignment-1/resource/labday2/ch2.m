function [channel_estimate] = ch2(x, y,L_hat)
%USAGE
%creates channel estimate by Matched Filter
%input x and y vector 
%input L_hat:
%   - specifies L 
%       or
%   - can be set to 0 to use default length for L: 
%       L = length(y)-length(x)+1
if L_hat == 0
    L =length(y)-length(x)+1;
else
    L = L_hat;
end
%THIS METHOD DOES NOT WORK
xr = flipud(x);
channel_estimate = filter(xr,1,y);
channel_estimate=channel_estimate(length(x)+1:end);
alpha =x'*x;
channel_estimate=channel_estimate/alpha;


%% plot the channel estimate
figure
plot(channel_estimate,'ro','MarkerSize',15,'MarkerFaceColor','r')
ylim([min(channel_estimate-1) max(channel_estimate+1)])
xlim([0 length(channel_estimate)+1])
%draw lines to x axis
for i=1:length(channel_estimate)
    line([i i],[0 channel_estimate(i)],'LineStyle','-','LineWidth',2,'Color','r')
end
%draw x axis
line([0 length(channel_estimate)+1],[0 0],'LineStyle','-','LineWidth',2)
end
