measurement = 3;

% Sample frequency
Fs = 44100;

% Synchronization
trim_threshold = .85;
trim_padding = 700;

% Peak detection
peak_threshold = .2;

% Localization
speed_sound = 330;

% Progress:
% data22
% peak: .38, trim: .85, sound: 353.5 (old peak algorithm, amp based)
% peak: .5, trim: .85, sound: ? (new algorithm)
% 1: ok
% 2: ok
% 3: ok
% 4: ok
% 5: ok
% 6: ok
% 7: ok

% Notes:
% - Piek algoritme is twijfelachtig... maar werkt!

% Get received signals
data = RXXr(measurement,:,:);
data = reshape(data,size(data,2),size(data,3));
rec = trim_data(data, trim_threshold, trim_padding);

% Calculate impulse responses of channel
h = [];
th = [];
d = [];
for i = 1:5
    [h(:,i) d(i)] = est_h(rec(:,i), M{i}, Fs, peak_threshold);
    
    % Threshold plot
    thi = round(d(i)*Fs);
    th(1:(thi-1),i) = 0;
    th(thi:size(h,1),i) = max(h(:,i));
end

figure(1);
% Plot
for i = 1:5
    subplot(5,1,i);
    t = (1:size(h,1))/Fs;
    plot(t, h(:,i), t, th(:,i), 'r');
    title(['Impulse response (channel ' num2str(i) ')']);
    grid on;
    xlabel 'Time (s)';
    ylabel 'Amplitude';
end

R = [];
% Generate R matrix
for i = 1:5
    for j = 1:5
        R(i,j) = (d(i)-d(j))*speed_sound; % Should fit speed of sound!
    end
end

mics_2d = [
    0     0;
    0     2.9;
    2.9   2.9;
    2.9   0;
    -0.95 1.45
];

% Localization
loc = localize_smart(R, mics, 0.05);
% - 5th mic as reference
% - no SVD threshold
% - use no 3D localization
estimated_location = loc(1:2)'