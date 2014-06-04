classdef MapDrive
    properties (SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = MapDrive()
        end
        
        % Mapping
        function [PWMDrive] = Map(Self, DriveExcitation, CurrentAngle)
            PWMDrive = 0;
        end
    end
end

