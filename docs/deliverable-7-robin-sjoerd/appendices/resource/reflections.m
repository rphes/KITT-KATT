%% Config
room_width = 4; % 4
room_height = 4; % 4
tx = [1.2 0.3]; % 1.2 0.3
rx = [3.1 3.3]; % 3.1 3.3
beta = 1; % Train: 200
v = 343; % Train: /10
copies = 5;

pulse_width = 5e-2;
pulse_amplitude = 1;
time_scale = 3;
N = 1e4;

rx_space = [];
h = [];
pulse = @(t) (heaviside(t)-heaviside(t-pulse_width))*pulse_amplitude;
copy_range = -copies:copies;

%% Calculation
for x=copy_range
    for y=copy_range
        mirror_x = mod(x,2);
        mirror_y = mod(y,2);
        
        % Mirror
        room_rx_x = rx(1);
        room_rx_y = rx(2);
        
        if mirror_x
            room_rx_x = room_width-room_rx_x;
        end
        
        if mirror_y
            room_rx_y = room_height-room_rx_y;
        end
        
        % Shift
        room_rx_x = room_rx_x + x*room_width;
        room_rx_y = room_rx_y + y*room_height;
        
        % Save
        rx_space = [rx_space;room_rx_x room_rx_y];
    end
end

for i=1:length(rx_space)
    % Get reflection count
    d_rooms_x = abs(floor(rx_space(i,1)/room_width));
    d_rooms_y = abs(floor(rx_space(i,2)/room_height));
    reflection_count = d_rooms_x+d_rooms_y;
    
    % Get path length
    path = sqrt((tx(1)-rx_space(i,1))^2+(tx(2)-rx_space(i,2))^2);
    
    % Calculate attentuation and delay
    att = beta/path^2;
    delay = path/v;
    
    % Add
    h = [h; delay att];
end

% Calculate system response
t = 0:(pulse_width*time_scale/(N-1)):(pulse_width*time_scale);
inp = pulse(t);
outp = zeros(1,length(inp));

for i=1:size(h,1)
    outp = outp+pulse(t-h(i,1))*h(i,2);
end

% Echo train!
% load gong;
% load handel;
% load train;
% hd_n = round(h(:,1)*Fs);
% hd_len = max(hd_n);
% hd = zeros(1,max(hd_len)+1);
% 
% for i=1:length(hd_n)
%     hd(hd_n(i)+1) = hd(hd_n(i)+1) + h(i,2);
% end
% 
% p = audioplayer(y,Fs);
% y2 = conv(hd,y);
% p2 = audioplayer(y2,Fs);
% play(p2);

%% Plot
close all;
figure(1);
plot(rx_space(:,1)',rx_space(:,2)','o',tx(1),tx(2),'x');
xlim([min(copy_range)*room_width (max(copy_range)+1)*room_width]);
ylim([min(copy_range)*room_height (max(copy_range)+1)*room_height]);
xlabel 'X (m)';
ylabel 'Y (m)';
title 'Rooms';
grid on;
set(gca,'XTick',copy_range*room_width);
set(gca,'YTick',copy_range*room_height);

figure(2);
plot(h(:,1)',h(:,2)','o');
grid on;
ylabel 'Delta pulse weight';
xlabel 'Time (t)';
title 'Impulse response delta pulses';

figure(3);
plot(t,inp,t,outp);
xlabel 'Time (t)';
ylabel 'Signal amplitude';
title 'System behaviour';
legend({'x(t)','y(t)'});
grid on;