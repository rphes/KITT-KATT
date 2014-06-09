classdef Route < handle
    properties (SetAccess = private)
        referenceAngle
        overflowTimer
    end
    
    methods
        %% Constructor
        function Self = Route()
            Self.overflowTimer = 0;
        end
        
        % Determine route
        function [CurrentDistance, ReferenceAngle] = DetermineRoute(Self, CurrentLocation, CurrentAngle, Waypoint, SensorData)
            % If distance to target is greater than two times the turning
            % radius, use the fancy algorithm
            StraightDistance = norm(CurrentLocation - Waypoint);
            if StraightDistance > Configuration.CarTurningRadius*2
                CurrentDistance = Self.DetermineDistance(CurrentLocation, CurrentAngle, Waypoint);
            else
                CurrentDistance = StraightDistance;
            end

            TargetReferenceAngle = Self.DetermineReferenceAngle(CurrentLocation, CurrentAngle, Waypoint);
            
            % This controller's first scope is to reach the target.
            % However, when an obstacle is detected, the controller
            % switches to the second scope in which its focus is fully on
            % avoiding the obstacle. After a clear path is detected, the car
            % resumes its journey to the destination.
            
            SensorDataMin = min(SensorData);
            
            % Obstacle is detected, calculate reference angle
            if SensorDataMin < Configuration.RouteThreshold
                % Reset overflow timer
                Self.overflowTimer = tic;
                
                % Switch to the obstacle avoidance scope
                CurrentDistance = SensorDataMin;
                
                % Determine the path which must be taken
                DeltaAngle = atan((Configuration.CarWidth/2 + Configuration.RouteClearance) / SensorDataMin);
                
                if SensorData(1) > SensorData(2)
                    Self.referenceAngle = CurrentAngle + DeltaAngle;
                else
                    Self.referenceAngle = CurrentAngle - DeltaAngle;
                end
            
            % Check if the overflow timer has expired
            elseif (Self.overflowTimer > 0) && (toc(Self.overflowTimer) >= Configuration.RouteOverflowTime)
                Self.overflowTimer = 0;
            
            % Check if overflow is busy
            elseif (Self.overflowTimer > 0) && (toc(Self.overflowTimer) < Configuration.RouteOverflowTime)
                % Keep reference angle
            
            % Check if nothing is going on
            else
                % Set reference angle to follow route
                Self.referenceAngle = TargetReferenceAngle;
            end
            
            % Return reference angle
            ReferenceAngle = Self.referenceAngle;
        end
        
        %% Determine reference angle
        function [ReferenceAngle] = DetermineReferenceAngle(~, CurrentLocation, CurrentAngle, Waypoint)
            % Transformation matrices
            TransformationOrthogonal = [0 -1;1 0];
            
            % Determine angle difference
            CarDirection = [cos(CurrentAngle); sin(CurrentAngle)];
            CarDirectionIdeal = Waypoint - CurrentLocation;
            CarDirectionIdeal = CarDirectionIdeal/norm(CarDirectionIdeal);
            
            AngleDiff = acos(dot(CarDirection, CarDirectionIdeal)); % Should already be normalized
            MaxAngle = asin(Configuration.CarLength/Configuration.CarTurningRadius);
            
            % Clamp angle diff
            if (AngleDiff < 0) && (AngleDiff < -MaxAngle)
                AngleDiff = -MaxAngle;
            elseif (AngleDiff > 0) && (AngleDiff > MaxAngle)
                AngleDiff = MaxAngle;
            end
            
            % Determine which direction to steer and calculate reference
            % angle by using the orthogonal transformation trick
            CarDirectionIdealOrthogonal = TransformationOrthogonal*CarDirectionIdeal;
            if dot(CarDirectionIdealOrthogonal,CarDirection) > 0
            	ReferenceAngle = CurrentAngle - AngleDiff;
            else
                ReferenceAngle = CurrentAngle + AngleDiff;
            end
        end
        
        %% Determine remaining distance
        function [CurrentDistance] = DetermineDistance(~, CurrentLocation, CurrentAngle, Waypoint)
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
            global TurningPoint
            TurningPoint1Distance = norm(TurningPoint1 - Waypoint);
            TurningPoint2Distance = norm(TurningPoint2 - Waypoint);
            if TurningPoint1Distance < TurningPoint2Distance
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
            CenterVector = CurrentLocation - TurningPoint;
            CenterVectorOrthogonal = TransformationOrthogonal*CenterVector;
            OrientationAngle = dot(CenterVectorOrthogonal, CarDirection);
            if OrientationAngle > 0
                Orientation = 1;
            else
                Orientation = -1;
            end
            
            % Determine angles
            TanPoint1Ref = TanPoint1 - TurningPoint;
            TanPoint2Ref = TanPoint2 - TurningPoint;
            CarRef = CurrentLocation - TurningPoint;
            TanPoint1Angle = atan2(TanPoint1Ref(2), TanPoint1Ref(1));
            TanPoint2Angle = atan2(TanPoint2Ref(2), TanPoint2Ref(1));
            CarAngle = atan2(CarRef(2), CarRef(1));

            % Order angles
            while TanPoint1Angle < CarAngle
                TanPoint1Angle = TanPoint1Angle + 2*pi;
            end
            while TanPoint2Angle < CarAngle
                TanPoint2Angle = TanPoint2Angle + 2*pi;
            end
            
            % Determine tangent point
            global TanPoint;
            if Orientation > 0
                if TanPoint2Angle > TanPoint1Angle
                    TanPoint = TanPoint1;
                    DeltaAngle = TanPoint1Angle - CarAngle;
                else
                    TanPoint = TanPoint2;
                    DeltaAngle = TanPoint2Angle - CarAngle;
                end
            else
                if TanPoint2Angle < TanPoint1Angle
                    TanPoint = TanPoint1;
                    DeltaAngle = TanPoint1Angle - CarAngle;
                else
                    TanPoint = TanPoint2;
                    DeltaAngle = TanPoint2Angle - CarAngle;
                end
            end
            
            % Circle distance
            CircleTrajectoryDistance = abs(DeltaAngle*Configuration.CarTurningRadius);
            
            %% Conclusion
            CurrentDistance = CircleTrajectoryDistance + TangentTrajectoryDistance;
        end
    end
end
