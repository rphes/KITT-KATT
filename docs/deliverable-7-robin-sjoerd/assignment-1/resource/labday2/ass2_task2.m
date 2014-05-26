%% USING TIME DOMAIN DECONVOLUTION
%settings:
%amount of samples to search:
close all;
Fs=44100;
samples = 5/340*Fs;
TDOA=[];
disp('Calculating 1st channel estimate (time)');
tstart=tic;
channel1_estimate = ch1(x,y(:,1),500);
elapsed=toc(tstart);
disp(strcat('took ',num2str(elapsed),'seconds'));
disp('Calculating 2nd channel estimate (time)');
tstart=tic;
channel2_estimate = ch1(x,y(:,2),500);
elapsed=toc(tstart);
disp(strcat('took ',num2str(elapsed),'seconds'));

disp('Finding maxima')
[peaks1 locs1] = findpeaks(abs(channel1_estimate),'SORTSTR','descend','MINPEAKDISTANCE',50,'NPEAKS',1);
[peaks2 locs2] = findpeaks(abs(channel2_estimate),'SORTSTR','descend','MINPEAKDISTANCE',50,'NPEAKS',1)

figure(1)
subplot(4,1,1)
hold on;
plot(channel1_estimate);
plot(locs1,channel1_estimate(locs1),'rx','MarkerSize',10);
subplot(4,1,2)
hold on;
plot(channel2_estimate);
plot(locs2,channel2_estimate(locs2),'rx','MarkerSize',10);

TDOA = [TDOA abs(locs2-locs1)/22050];

%% USING MATCHED FILTER
disp('Calculating 1st channel estimate (matched filter)');
tstart=tic;
channel1_estimate = ch2(x,y(:,1),0);
elapsed=toc(tstart);
disp(strcat('took ',num2str(elapsed),'seconds'));
tstart=tic;
disp('Calculating 2nd channel estimate (matched filter)');
elapsed=toc(tstart);
disp(strcat('took ',num2str(elapsed),'seconds'));
channel2_estimate = ch2(x,y(:,2),0);

disp('Finding maxima')
[peaks1 locs1] = findpeaks(abs(channel1_estimate),'SORTSTR','descend','MINPEAKDISTANCE',ceil(length(channel1_estimate)/2));
if(locs1(1)>locs1(2))
    locs1=locs1(2);
else
    locs1=locs1(1);
end
begin_interval=locs1(1)-samples;
end_interval=locs1(1)+samples;
if begin_interval<1
    begin_interval=1;
end
if end_interval>length(channel2_estimate)
    end_interval=length(channel2_estimate);
end

search_interval = int64(begin_interval):int64(end_interval);
[peaks2 locs2] = findpeaks(abs(channel2_estimate(search_interval)),'SORTSTR','descend');
locs2 = int64(locs2+locs1-samples-1);
figure(1)
subplot(4,1,3)
hold on;
plot(channel1_estimate);
plot(locs1,channel1_estimate(locs1),'rx','MarkerSize',10);
subplot(4,1,4)
hold on;
plot(channel2_estimate);
plot(locs2(1),channel2_estimate(locs2(1)),'rx','MarkerSize',10);

TDOA = [TDOA double(abs(locs2(1)-locs1(1)))/Fs];
distance_between_mics = TDOA*340
