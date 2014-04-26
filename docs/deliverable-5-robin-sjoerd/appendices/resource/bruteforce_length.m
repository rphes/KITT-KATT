%% Find transmission line length using multiple measurements
clc; clear;

disp('Calculating possible lengths...');
l1 = get_length(26.5 - 10.4i, 50, 100, 9.65e9, 2.205, 3);
l2 = get_length(73.6 + 35.8i, 50, 100, 9.85e9, 2.205, 3);
l3 = get_length(39.1 + 29.3i, 50, 100, 10e9, 2.205, 3);

disp('Starting brute-force...');
num_iterations = length(l1) * length(l2) * length(l3);
disp(['Will iterate ' num2str(num_iterations) ' times']);

start = tic;
min_dev = 999;
for i = 1:length(l1)
    for j = 1:length(l2)
        for k = 1:length(l3)
            a = max([abs(l1(i) - l2(j)) abs(l1(i) - l3(k)) abs(l2(j) - l3(k))]);
            if a < min_dev
                min_dev = a;
                l = mean([l1(i) l2(j) l3(k)]);
            end    
        end
    end
end

time = toc(start);
disp(['Done in ' num2str(time) ' seconds']);
disp(['Transmission line length is ' num2str(l) ' m']);