%% tweaking find_start_sjoerd params
% this file is used only for TESTING THE PARAMETERS
% not used in the end
threshold=7;
interval_length=5;


for i=1:5
    start = find_start_sjoerd(h(:,i),threshold,interval_length);
    subplot(5,1,i);
    hold on;
    plot(h(:,i));
    th = max(h(:,i))*[zeros(1,length(h(1:start,i))) ones(1,length(h(start+1:end,i)))];
    plot(th,'r');
end