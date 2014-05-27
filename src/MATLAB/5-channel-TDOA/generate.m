% Impulse reponse length
L = 3000;

% Sample length
len = 600;

% Noise reduction
svd_level = 0.5;

% Peak detection
level = 0.5;

% Padding
padding = 200;

% Sample frequency
Fs = 44100;

close all;

ref = {};
for i = 1:5
	ref{i} = RXXr(i,:,i);
    
    % Assume clean signal
    max_level = max(ref{i});
    for start = 1:length(ref{i})
        if ref{i}(start) > max_level*level
            break
        end
    end
    
    % Sync ref signal
    if start-padding > 0
        ref{i} = ref{i}((start-padding):length(ref{i}));
    else
        ref{i} = [zeros(1,padding-start) ref{i}];
    end
    
    % Cut signal
%     ref{i} = ref{i}(1:len);
    
    % Plot
    display(['Channel ' num2str(i)]);
    subplot(5,1,i);
    t = (1:length(ref{i}))/Fs;
    plot(t,ref{i});
    title(['Channel ' num2str(i)]);
    xlabel 'Time (t)';
    ylabel 'Amplitude';
    grid on;
    drawnow;
    
    % Calculate deconvolution matrix
    M{i} = deconv_matrix(ref{i}, L, svd_level);
end
