function [ImpulseResponse, Delay] = EstimateChannel(Data, DeconvolutionMatrix, Fs, PeakThreshold)
    % Fix orientation
    if size(Data,2) > 1
        Data = Data';
    end    
    
    VectorLength = size(DeconvolutionMatrix,2);
    LengthDifference = VectorLength-length(Data);
    
    if LengthDifference > 0
        Data = [Data;zeros(LengthDifference,1)];
    elseif LengthDifference < 0
        Data = Data(1:VectorLength);
    end
    
    ImpulseResponse = DeconvolutionMatrix*Data;
    
    % Find delay
    Delay = FindStart(ImpulseResponse, PeakThreshold)/Fs;
end