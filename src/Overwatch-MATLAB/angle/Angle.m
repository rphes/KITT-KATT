classdef Angle
    properties (SetAccess = private)
        currentLocation
        currentAngle
    end
    
    methods
        % Constructor
        function Self = Angle(InitialLocation, InitialAngle)
            Self.currentLocation = InitialLocation;
            Self.currentAngle = InitialAngle;
        end
        
        % Determine route
        function [CurrentAngle] = DetermineAngle(Self, NewLocation)
            % First determine angle of the car
            Dx = NewLocation(1) - Self.currentLocation(1);
            Dy = NewLocation(2) - Self.currentLocation(2);
            
            % If both Dx and Dy are zero, the car does not move, and the
            % angle has not changed
            if (Dx ~= 0) && (Dy ~= 0)
                Self.currentAngle = atan2(Dy, Dx);
            end
            
            % Save new location and angle
            Self.currentLocation = NewLocation;
            CurrentAngle = Self.currentAngle;
        end
    end
end

