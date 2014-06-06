classdef MapSteer
    properties (SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = MapSteer()
        end
        
        % Mapping
        function [PWMSteer] = Map(~, SteerExcitation)
            if abs(SteerExcitation) < Configuration.MapSteerBound
                PWMSteerRaw = 150;
            else
                if SteerExcitation > 0
                    PWMSteerRaw = 150 + ...
                        Configuration.MapSteerFOC*(SteerExcitation - Configuration.MapSteerBound) + ...
                        Configuration.MapSteerTOC*(SteerExcitation - Configuration.MapSteerBound)^3;
                else
                    PWMSteerRaw = 150 + ...
                        Configuration.MapSteerFOC*(SteerExcitation + Configuration.MapSteerBound) + ...
                        Configuration.MapSteerTOC*(SteerExcitation + Configuration.MapSteerBound)^3;
                end
            end
        
            PWMSteer = round(PWMSteerRaw);
        end
    end
end

