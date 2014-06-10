load refdata

% Impulse reponse length
ImpulseResponseLength = 3500;

% Sample length
Length = 500;

% Peak detection
PeakThreshold = 0.3;

% Padding
DataPadding = 50;
DataCut = [0 0 0 0 0];

% Sample frequency
Fs = 48000;

% Filter settings
UseMatchedFilter = 0;
InversionSVDThreshold = [0.1 0.2 0.5 0.2 0.015];

close all;

Reference = {};
for i = 1:5
    Reference{i} = RecordData{i}(:,i);
    
    % Cut
    Reference{i} = Reference{i}((1+DataCut(i)):length(Reference{i}));
   
    % Assume clean signal
    Start = FindStart(Reference{i}, PeakThreshold);
    
    % Sync ref signal
    if Start-DataPadding > 0
        Reference{i} = Reference{i}((Start-DataPadding):length(Reference{i}));
    else
        Reference{i} = [zeros(1,DataPadding-Start) Reference{i}];
    end
    
    % Cut signal
    Reference{i} = Reference{i}(1:Length);
    
    % Plot
    display(['Channel ' num2str(i)]);
    subplot(5,1,i);
    t = (1:length(Reference{i}))/Fs;
    plot(t,Reference{i});
    title(['Channel ' num2str(i)]);
    xlabel 'Time (t)';
    ylabel 'Amplitude';
    grid on;
    drawnow;
    
    % Calculate deconvolution matrix
    DeconvolutionMatrix{i} = GenerateDeconvolutionMatrix(Reference{i}, ImpulseResponseLength, InversionSVDThreshold(i), UseMatchedFilter);
end
