classdef Route
    properties (SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = Route()
        end
        
        % Determine route
        function [CurrentDistance, ReferenceAngle] = DetermineRoute(~, CurrentLocation, CurrentAngle, Waypoints, SensorData)
            % Take first waypoints
            Waypoint = Waypoints(1,:);
        
            % Transformation matrices
            TransformationOrthogonal = [0 -1;1 0];
        
            % Direction vector of car
            CarDirection = [cos(CurrentAngle); sin(CurrentAngle)];
            CarDirectionPerpendicular = TransformationOrthogonal*CarDirection; % Note that this is a normalized vector!
            
            %% Determine turning point
            % Turning points
            TurningPoint1 = CurrentLocation + Configuration.CarTurningRadius*CarDirectionPerpendicular;
            TurningPoint2 = CurrentLocation - Configuration.CarTurningRadius*CarDirectionPerpendicular;
            
            % Choose turning point which is closest to waypoint
            if norm(TurningPoint1 - Waypoint) < norm(TurningPoint2 - Waypoint)
                TurningPoint = TurningPoint1;
            else
                TurningPoint = TurningPoint2;
            end
        
            %% Tangent distance
            % Distance to turning point
            TPDistanceVector = TurningPoint - Waypoint;
            TPDistance = norm(TPDistanceVector);
            
            % Trajectory distance on the tangent line
            TangentTrajectoryDistance = sqrt(TPDistance^2 - Configuration.CarTurningRadius^2);
            
            %% Circle distance
            % Calculate both tangent points
            TPDistanceVectorOrthogonal = TransformationOrthogonal*TPDistanceVector;
            TPDistanceVectorOrthogonal = TPDistanceVectorOrthogonal/norm(TPDistanceVectorOrthogonal); % Normalize
            TanPoint1 = TurningPoint + Configuration.CarTurningRadius*TPDistanceVectorOrthogonal;
            TanPoint2 = TurningPoint - Configuration.CarTurningRadius*TPDistanceVectorOrthogonal;
            
            % Determine circle orientation
            
            
            CurrentDistance = 0;
            ReferenceAngle = 0;
        end
    end
end
