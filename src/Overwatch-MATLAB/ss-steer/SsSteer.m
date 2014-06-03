classdef SsSteer
    properties (SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = SsSteer()
        end
        
        % Iteration
        function [CurrentAngle, SteerExcitation] = Iterate(Self, CurrentLocation, ReferenceAngle, BatteryVoltage)
            CurrentAngle = 0;
            SteerExcitation = 0;
        end
    end
end

