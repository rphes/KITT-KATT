N_x = 10;

seqs_desc = {'minimum phase','maximum phase','sinusoidal','BPSK'};%,'step','delta pulse'};
% Create signals
x = {};
x{1} = [1 -1/2 zeros(1,N_x-2)]; % Min phase
x{2} = [1 -2 zeros(1,N_x-2)]; % Max phase
x{3} = cos(0.2*(0:(N_x-1))); % Sinusoidal
x{4} = sign(randn(N_x,1))'; % BPSK
% x{5} = ones(1,N_x); % Step
% x{6} = zeros(1,N_x); x{6}(1) = 1; % Delta

% Channel
h_channel = [3 1 2 -4];

% Noise
sigma = 0;
display(['Noise variance: ' num2str(round(sigma*100)/100)]);
display ' ';
noise = sigma*randn(N_x+length(h_channel)-1,1)';

% Outputs
y = {};
for i = 1:length(x)
    y{i} = conv(h_channel, x{i})+noise;
end

% Estimation methods
methods = {@est_project, @est_matched};
methods_desc = {'Projection','Matched estimation'};