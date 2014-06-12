classdef MapSteer < handle
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
            
            % Check for maximum value
            if (PWMSteer > 0) && PWMSteer > 200
                PWMSteer = 200;
            elseif (PWMSteer < 0) && PWMSteer < 100
                PWMSteer = 100;
            end
        end
    end
end

