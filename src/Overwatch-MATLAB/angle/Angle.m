classdef Angle < handle
    properties (SetAccess = private)
        currentPosition
        currentAngle
    end
    
    methods
        % Constructor
        function Self = Angle(InitialPosition, InitialAngle)
            Self.currentPosition = InitialPosition;
            Self.currentAngle = InitialAngle;
        end
        
        % Determine route
        function [CurrentAngle] = DetermineAngle(Self, NewPosition)      
            % First determine angle of the car
            DeltaLocation = NewPosition - Self.currentPosition;
            
            % Save new location and angle
            Self.currentPosition = NewPosition;
            
            % If both Dx and Dy are zero, the car does not move, and the
            % angle has not changed
            if norm(DeltaLocation) > 0.001
                Self.currentAngle = atan2(DeltaLocation(2), DeltaLocation(1));
            end
            
            CurrentAngle = Self.currentAngle;
        end          
    end
end

