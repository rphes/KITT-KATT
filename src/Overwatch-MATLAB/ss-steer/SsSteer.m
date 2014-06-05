classdef SsSteer
    properties (SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = SsSteer()
        end
        
        % Iteration
        function [SteerExcitation] = Iterate(~, CurrentAngle, ReferenceAngle, ~) % BatteryVoltage
            % Calculate excitation
            SteerExcitation = Configuration.SteeringFeedbackCoefficient * (CurrentAngle - ReferenceAngle);
        end
    end
end

