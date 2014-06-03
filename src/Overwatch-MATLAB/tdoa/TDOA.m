classdef TDOA
    properties (SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = TDOA()
        end
        
        % Check if TDOA determination is busy
        function Ret = IsBusy(Self)
            Ret = 0;
        end
        
        % Check if TDOA determination is ready
        function Ret = IsReady(Self)
            Ret = 0;
        end
        
        % Start TDOA determination
        function Start(Self)
        end
        
        % Range difference matrix retrieval function
        function RangeDiffMatrix = GetRangeDiffMatrix(Self)
            RangeDiffMatrix = [];
        end
    end
end

