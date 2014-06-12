function [DeconvulationMatrix, VectorLength] = GenerateDeconvolutionMatrix(Data, ImpulseResponseLength, SVDThreshold, UseMatchedFilter)
    % Fix orientation
    if size(Data,1) > 1
        Data = Data';
    end

    Timer = tic;
    DataLength = length(Data);
    VectorLength = ImpulseResponseLength+DataLength-1;
    
    display 'Building Toeplitz matrix';
    % Build toeplitz matrix
    ToeplitzMatrix = fliplr([zeros(1,ImpulseResponseLength-1) fliplr(Data)]);
    ToeplitzMatrix = tril(toeplitz(ToeplitzMatrix));
    ToeplitzMatrix = ToeplitzMatrix(:,1:(size(ToeplitzMatrix,2)-length(Data)+1));
    
    if UseMatchedFilter
        display 'Calculating matched filter';
        DeconvulationMatrix = ToeplitzMatrix;
    else
        display 'Calculating inverse filter';
        DeconvulationMatrix = (ToeplitzMatrix*SVDFilter(ToeplitzMatrix'*ToeplitzMatrix, SVDThreshold, 1))';   
    end
    
    % Report
    Time = toc(Timer);
    display(['Time: ' num2str(round(100*Time)/100) ' s']);
end

