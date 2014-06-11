classdef TDOA < handle
    properties (SetAccess = private)
        errorAverage = 0.02;
        errorSTD = 0.01;
    end
    
    methods
        function RetrieveDeconvolutionMatrix(~)
            % Do nothing
        end
        
        % Range difference matrix retrieval function
        function RangeDiffMatrix = GetRangeDiffMatrix(Self)
            global tdoaSimLocation
            
            % Get mics
            Mics = Configuration.LocMics;
            
            % Generate range of arrivals
            ROAs = [];
            for i = 1:size(Mics, 1)
                ROAs(i) = norm(tdoaSimLocation - Mics(i,:)') + Self.errorAverage + Self.errorSTD*randn();
            end
            
            % Generate range diff matrix
            RangeDiffMatrix = [];
            for i = 1:size(Mics, 1)
                for j = (i+1):size(Mics, 1)
                    RangeDiffMatrix(i,j) = ROAs(i) - ROAs(j);
                    RangeDiffMatrix(j,i) = -RangeDiffMatrix(i,j);
                end
            end
        end
    end
end

