classdef Obstacles < handle
    properties (SetAccess = private)
        % Car properties
        sensorSpacing = 0.2
        maxSensorValue = 3
        
        obstacles
        
        % Drawing
        XDatas = {}
        YDatas = {}
    end
    
    methods
        function Self = Obstacles(obstacles)
            Self.obstacles = obstacles;
        end
        
        function [SensorData] = DetermineSensorDistances(Self, CurrentPosition, CurrentAngle)
            % Determine the direction in which the car is looking
            CarDirection = [cos(CurrentAngle); sin(CurrentAngle)];
            CarDirectionOrthogonal = [0 -1;1 0]*CarDirection;
            
            % Determine sensor positions and directions
            SensorDirection = CarDirection;
            SensorPosition1 = CurrentPosition + CarDirectionOrthogonal*Self.sensorSpacing/2;
            SensorPosition2 = CurrentPosition - CarDirectionOrthogonal*Self.sensorSpacing/2;
            
            % Determine sensor data
            SensorData = [Self.DetermineDistance(SensorDirection, SensorPosition1) Self.DetermineDistance(SensorDirection, SensorPosition2)];
        end
        
        % Determine sphere line intersections
        function [Distance] = DetermineDistance(Self, LineDirection, LineSupport)
            Distance = Self.maxSensorValue;
        
            for i = 1:size(Self.obstacles, 1)
                % Current obstacle
                Obstacle = Self.obstacles(i, :);
                
                % Determine sphere dimensions
                SpherePosition = Obstacle(1:2)';
                SphereRadius = Obstacle(3);

                % Solve intersections
                A = norm(LineDirection,2)^2;
                B = 2*dot(LineDirection, LineSupport-SpherePosition);
                C = norm(LineSupport-SpherePosition)^2 - SphereRadius^2;
                D = B^2-4*A*C;
                
                Lambdas = [];
                
                if D >= 0
                    Lambdas = [Lambdas (-B+sqrt(D))/(2*A)];
                    Lambdas = [Lambdas (-B-sqrt(D))/(2*A)];
                end
                
                % Filter negative lambdas
                Lambdas = Lambdas(Lambdas >= 0);

                % Update distance
                if length(Lambdas) > 0
                    DistanceBest = min(Lambdas);
                    
                    if DistanceBest < Distance
                        Distance = DistanceBest;
                    end
                end
            end
        end
        
        % Generate data
        function PrepareDraw(Self)
            Resolution = 100;
            ThetaData = (2*pi/Resolution):(2*pi/Resolution):(2*pi);
            
            hold on;
            
            for i = 1:size(Self.obstacles, 1)
                % Current obstacle
                Obstacle = Self.obstacles(i, :);
                
                % Empty data sets
                XData = [];
                YData = [];
                
                % Determine sphere dimensions
                SpherePosition = Obstacle(1:2)';
                SphereRadius = Obstacle(3);
                
                % Collect points
                for j = 1:length(ThetaData)
                    Direction = [cos(ThetaData(j)); sin(ThetaData(j))];
                    Point = SpherePosition + SphereRadius*Direction;
                    
                    % Add data
                    XData = [XData Point(1)];
                    YData = [YData Point(2)];
                end
                
                Self.XDatas{length(Self.XDatas)+1} = XData;
                Self.YDatas{length(Self.YDatas)+1} = YData;
            end      
        end
        
        % Draw
        function Draw(Self)
            for i = 1:length(Self.XDatas)
                plot(Self.XDatas{i}, Self.YDatas{i}, 'green');
            end
        end
    end
end

