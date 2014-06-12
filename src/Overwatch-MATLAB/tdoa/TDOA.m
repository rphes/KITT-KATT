classdef TDOA < handle
    properties (SetAccess = private)
        deconvolutionMatrix
    end
    
    methods
        function RetrieveDeconvolutionMatrix(Self)
            global DeconvolutionMatrix
            Self.deconvolutionMatrix = DeconvolutionMatrix;
        end
        
        % Range difference matrix retrieval function
        function RangeDiffMatrix = GetRangeDiffMatrix(Self)
            Data = pa_wavrecord(1, 5, Configuration.TDOARecordingTime*Configuration.Fs, Configuration.Fs, 0, 'asio');
            
            TrimmedData = TrimData(Data,...
                Configuration.Fs,...
                Configuration.TDOATrimPeakThreshold,...
                Configuration.TDOATrimPeakFrequency,...
                Configuration.TDOATrimSkipCoefficient,...
                Configuration.TDOATrimClearanceAfter,...
                Configuration.TDOATrimClearanceBefore);
    
            % Check if no valid peaks were found
            if isempty(TrimmedData)
                RangeDiffMatrix = [];
                return
            end    

            [RangeDiffMatrix, ~, ~, ~] = GenerateRangeDiffMatrix(TrimmedData, Self.deconvolutionMatrix, Configuration.Fs, Configuration.TDOAImpulsePeakThreshold, Configuration.TDOASoundSpeed);
        end
    end
end

