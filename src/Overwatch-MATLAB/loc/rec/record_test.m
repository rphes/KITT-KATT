%% Record a sound with laptop and plot original and trimmed signals
% test is done 5 times to simulate 5 channels
addpath('laptop_test');

for i=1:5
    temp = recordLaptop(1);
    length(temp)
    y(:,i) = temp(1:40000);
end

[res, start] = trim_5chan(y, 500, 20);
for i=1:5
    subplot(5,1,i)
    plot(y(:,i));
    hold on;
    plot([zeros(start-1,1); ones(length(y)-start,1)],'r')
end
