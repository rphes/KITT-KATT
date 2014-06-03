classdef Route
    properties (SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = Route()
        end
        
        % Determine route
        function [CurrentDistance, ReferenceAngle] = DetermineRoute(Self, CurrentLocation, Waypoints, SensorValues)
            CurrentDistance = 0;
            ReferenceAngle = 0;
        end
    end
end

