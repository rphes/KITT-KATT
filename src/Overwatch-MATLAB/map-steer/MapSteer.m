classdef MapSteer
    properties (SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = MapSteer()
        end
        
        % Mapping
        function [PWMSteer] = Map(~, SteerExcitation)
            if abs(SteerExcitation) < Configuration.SteerMapBound
                PWMSteerRaw = 150;
            else
                if SteerExcitation > 0
                    PWMSteerRaw = 150 + ...
                        Configuration.SteerMapFOC*(SteerExcitation - Configuration.SteerMapBound) + ...
                        Configuration.SteerMapFOC*(SteerExcitation - Configuration.SteerMapBound)^3;
                else
                    PWMSteerRaw = 150 + ...
                        Configuration.SteerMapFOC*(SteerExcitation + Configuration.SteerMapBound) + ...
                        Configuration.SteerMapFOC*(SteerExcitation + Configuration.SteerMapBound)^3;
                end
            end
        
            PWMSteer = round(PWMSteerRaw);
        end
    end
end

