classdef SsDrive
    properties (SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = SsDrive()
        end
        
        % Iteration
        function [CurrentSpeed, DriveExcitation] = Iterate(Self, CurrentDistance, ReferenceDistance, BatteryVoltage)
            CurrentSpeed = 0;
            DriveExcitation = 0;
        end
    end
end

