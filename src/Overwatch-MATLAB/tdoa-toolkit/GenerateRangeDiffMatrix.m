function [RangeDiff, ImpulseResponse, ImpulseResponseDetection, Delays] = GenerateRangeDiffMatrix(Data, DeconvolutionMatrix, Fs, PeakThreshold, SoundSpeed)
    N = size(Data,2);
    
    Delays = [];
    ImpulseResponse = {};
    ImpulseResponseDetection = {};
    % Recover channel impulse responses
    for i = 1:N
        [ImpulseResponse{i}, Delays(i)] = EstimateChannel(Data(:,i), DeconvolutionMatrix{i}, Fs, PeakThreshold);
        
        % Generate detection
        ImpulseResponseDetection{i} = zeros(1,length(ImpulseResponse{i}));
        ImpulseResponseDetection{i}(round(Fs*Delays(i)):length(ImpulseResponseDetection{i})) = max(ImpulseResponse{i});
    end

    RangeDiff = [];
    % Generate R matrix
    for i = 1:N
        for j = (i+1):N
            RangeDiff(i,j) = (Delays(i)-Delays(j))*SoundSpeed;
            RangeDiff(j,i) = -RangeDiff(i,j);
        end
    end
end