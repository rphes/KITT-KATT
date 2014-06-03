classdef MapSteer
    properties (SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = MapSteer()
        end
        
        % Mapping
        function [PWMSteer] = Map(Self, SteerExcitation)
            PWMSteer = 0;
        end
    end
end

