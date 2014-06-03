classdef SsSteer
    properties (SetAccess = private)
        currentLocation
        currentAngle
    end
    
    methods
        % Constructor
        function Self = SsSteer(InitialLocation, InitialAngle)
            Self.currentLocation = InitialLocation;
            Self.currentAngle = InitialAngle;
        end
        
        % Iteration
        function [CurrentAngle, SteerExcitation] = Iterate(Self, NewLocation, ReferenceAngle, ~) % ~ = BatteryVoltage
            % First determine angle of the car
            Dx = NewLocation(1) - Self.currentLocation(1);
            Dy = NewLocation(2) - Self.currentLocation(2);
            
            % If both Dx and Dy are zero, the car does not move, and the
            % angle has not changed
            if (Dx ~= 0) && (Dy ~= 0)
                Self.currentAngle = atan2(Dy, Dx);
            end
            
            % Save new location and angle
            Self.currentLocation = NewLocation(1);
            CurrentAngle = Self.currentAngle;
            
            % Calculate excitation
            SteerExcitation = Configuration.SteeringFeedbackCoefficient * (CurrentAngle - ReferenceAngle);
        end
    end
end

