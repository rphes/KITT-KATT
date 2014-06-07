classdef Angle < handle
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
            DeltaLocation = NewLocation - Self.currentLocation;
            
            % If both Dx and Dy are zero, the car does not move, and the
            % angle has not changed
            if norm(DeltaLocation) > 0.01
                Self.currentAngle = atan2(DeltaLocation(2), DeltaLocation(1));
            end
            
            % Save new location and angle
            Self.currentLocation = NewLocation;
            CurrentAngle = Self.currentAngle;
        end
    end
end

