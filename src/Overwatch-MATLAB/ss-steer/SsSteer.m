classdef SsSteer
    properties (SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = SsSteer()
        end
        
        % Iteration
        function [SteerExcitation] = Iterate(~, CurrentAngle, ReferenceAngle, ~) % BatteryVoltage
            AngleDifference = CurrentAngle - ReferenceAngle;

            % Calculate excitation
            SteerExcitation = Configuration.SteeringFeedbackCoefficient * AngleDifference;
        end
    end
end

