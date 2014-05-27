%% General settings
noise_cm = 0;

%% Settings
use_3d = 0;
mode = 4;

% 1: Reference mic
refmic = 2;
% 2: Smart
smart_th = 0.3;
% 3: Manual + SVD filter
svd_th = 0.05;
% 4: Bancroft

%% Settings normal
normal_use_3d = 1;
normal_mode = 3;

% 1: Reference mic
normal_refmic = 5;
% 2: Smart
normal_smart_th = 0;
% 3: Manual + SVD filter
normal_svd_th = 0;
% 4: Bancroft

%% Process
% Progress:
% - ref mic bad
% - SVD 0.05 helps in symmetry with x < 0
% - smart 0.05 helps more in symmetry x < 0
% - 3D for non-symmetry situations

% Conclusions:
% - No 3D
% - Smart 0.05

% Data
mics = [
    0     0    0.38;
    0     2.9  0.38;
    2.9   2.9  0.38;
    2.9   0    0.38
    -0.95 1.45 0.93
];

beacon1 = [-0.65 1.43 0.3]; % Dichtbij mic 5
beacon2 = [1.45 1.43 0.3]; % Midden
beacon3 = [0.3 2.3 0.3]; % Linksboven
beacon4 = [2.5 .45 0.3]; % Rechtsonder
beacon5 = [0.05 2.83 0.3]; % Dichtbij mic 2
beacon6 = [2.83 2.87 0.3]; % Dichtbij mic 3

beacon = beacon3;

% Calculate RDOA's
rdoa_an = [];
offset = -.3;

for i = 1:size(mics,1)
    rdoa_an(i) = norm(mics(i,:)-beacon);
end

noise = noise_cm*1e-2;
locs = [];
locs_modded = [];
N = 1;

for i = 1:N
    % Add noise
    rdoa = rdoa_an;
    for i = 1:length(rdoa_an)
        rdoa(i) = rdoa(i) + randn(1,1)*noise;
    end
    
    % Calculate R matrix
    R = [];
    for i = 1:length(rdoa)
        for j = (i+1):length(rdoa)
            R(i,j) = rdoa(i)-rdoa(j);
            R(j,i) = -R(i,j);
        end
    end
    
    % Localization
    locs = [localize_wrapper(R, normal_refmic, normal_use_3d, normal_mode, normal_svd_th, normal_smart_th);locs];
    
    % Localization
    locs_modded = [localize_wrapper(R, refmic, use_3d, mode, svd_th, smart_th);locs_modded];
end

% Error analysis
err_locs = [];
err_locs_modded = [];
avg_err_locs = 0;
avg_err_locs_modded = 0;

for i = 1:size(locs)
    err_locs = [err_locs;norm(locs(i,:)-beacon(1:2))];
    avg_err_locs = avg_err_locs + err_locs(i)/N;
    
    err_locs_modded = [err_locs_modded;norm(locs_modded(i,:)-beacon(1:2))];
    avg_err_locs_modded = avg_err_locs_modded + err_locs_modded(i)/N;
    
end

bias = [0 0];
bias_modded = [0 0];

for i = 1:size(locs)
    bias = bias+(locs(i,:)-beacon(1:2))/N;
    bias_modded = bias_modded+(locs_modded(i,:)-beacon(1:2))/N;
end

display 'Normal stats'
display '-----------';
display(['DIST ERR AVG: ' num2str(round(avg_err_locs*100*1000)/1000)]);
display(['DIST ERR STD: ' num2str(round(std(err_locs)*100*1000)/1000)]);
display(['DIST BIAS:    ' num2str(round(norm(bias)*100*1000)/1000)]);
display ' '
display 'Modded stats'
display '-----------';
display(['DIST ERR AVG: ' num2str(round(avg_err_locs_modded*100*1000)/1000)]);
display(['DIST ERR STD: ' num2str(round(std(err_locs_modded)*100*1000)/1000)]);
display(['DIST BIAS:    ' num2str(round(norm(bias_modded)*100*1000)/1000)]);
display ' '
display 'Comparison'
display '-----------';
display(['DIST ERR AVG: ' num2str(round((avg_err_locs_modded-avg_err_locs)*100*1000)/1000)]);
display(['DIST ERR STD: ' num2str(round((std(err_locs_modded)-std(err_locs))*100*1000)/1000)]);
display(['DIST BIAS:    ' num2str(round((norm(bias_modded)-norm(bias))*100*1000)/1000)]);

% Plot
dot_size = 6;
plot(locs(:,1),locs(:,2),'o','MarkerFaceColor','blue','MarkerSize',dot_size);
hold on;
plot(locs_modded(:,1),locs_modded(:,2),'og','MarkerFaceColor','green','MarkerSize',dot_size);
hold on;
plot(beacon(1),beacon(2),'or','MarkerFaceColor','red','MarkerSize',10);
hold on;
plot(mics(:,1),mics(:,2),'o','MarkerFaceColor','black','MarkerSize',10);
hold off;
xlim([-3 4]);
ylim([-1 3]);
title 'Localization performance';
legend({'Estimation','Modified estimation','Actual location','Microphones'},...
    'Location','SouthEast');
grid on;
xlabel 'x (m)';
ylabel 'y (m)';
