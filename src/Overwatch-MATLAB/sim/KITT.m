classdef KITT < handle
    properties (SetAccess = private)
        % State-space model parameters
        carMass = 6; % Car mass
        carResistance = 0.15; % Car resistance
        motorInductance = 0.020; % Self-inductance
        motorConstant = 0.5; % Motor constant
        motorResistance = 0.05; % Motor resistance (current oscillation)
        wheelRadius = 0.15; % Wheel radius
        motorGearRatio = 20; % Gear ratio <!--- IMPORTANT ---!> (attack)
        
        % State-space model
        currentState = [0; 0; 0];
        A
        B
        C
        D
        
        % Tracks
        timer
        timerBegin
        distance = 0;
        currentPosition = [0; 0];
        currentAngle = 0;
        
        % Coefficients
        pwmCoefficient = 0.1;
        angleCoefficient
        
        % Car characteristics
        turningRadius = 0.65;
        carLength = 0.35;
        
        % State tracking
        states
        time        
    end
    
    methods
        function Self = KITT()
            GyratorConstant = Self.motorConstant/Self.wheelRadius/Self.motorGearRatio; % Gyrator constant

            % State-space model calculation
            Self.A = [
                    [0 1 0];
                    [0 -Self.carResistance/Self.carMass GyratorConstant/Self.carMass];
                    [0 -GyratorConstant/Self.motorInductance -Self.motorResistance/Self.motorInductance]
                ];
            Self.B = [0;0;1/Self.motorInductance];
            Self.C = [1 0 0];
            Self.D = 0;
            
            Self.timer = tic;
            Self.timerBegin = tic;
            
            % Coefficient calculation
            Self.angleCoefficient = asin(Self.carLength/Self.turningRadius)/50;
        end
        
        % New distance calculation by state-space model
        function [CurrentDistance, CurrentSpeed] = IterateDistance(Self, PWM, Dt)
            BatteryVoltage = Self.pwmCoefficient*PWM;            
            
            % State calculation by Eulers
            N = 100;
            NewState = Self.currentState;
             
            for i = 1:N
                r = Self.A*NewState + Self.B*BatteryVoltage;
                NewState = NewState + r*Dt/N;
            end
            
            Self.currentState = NewState;
            
            % Save
            Self.states = [Self.states NewState];
            Self.time = [Self.time toc(Self.timerBegin)];
            
            % Output calculation
            CurrentDistance = Self.currentState(1);
            CurrentSpeed = Self.currentState(2);    
        end
        
        % New position calculation
        function [CurrentPosition, CurrentSpeed, CurrentAngle] = Iterate(Self, PWMDrive, PWMSteer)
            % Delta time calculation
            Dt = toc(Self.timer);
            Self.timer = tic;
            
            % Dead-zone PWM correction
            if PWMDrive < 145
                PWMDriveNormalized = PWMDrive - 145;
            elseif PWMDrive > 155
                PWMDriveNormalized = PWMDrive - 155;
            else
                PWMDriveNormalized = 0;
            end
            
            [CurrentDistance, CurrentSpeed] = Self.IterateDistance(PWMDriveNormalized, Dt);
                
            % Delta distance calculation
            DeltaDistance = CurrentDistance - Self.distance;
            Self.distance = CurrentDistance;
            
            % Quick fix for edge case
            if PWMSteer == 150
                PWMSteer = 150.01;
            end
            
            SteerAngle = (PWMSteer - 150)*Self.angleCoefficient;
            
            % New position calculation
            [CurrentPosition] = Self.IteratePosition(DeltaDistance, SteerAngle);
            
            CurrentAngle = Self.currentAngle;
        end
        
        % Position calculation
        function [NewPosition] = IteratePosition(Self, DeltaDistance, SteerAngle)
            CurrentPosition = Self.currentPosition;
        
            % Turning radius calculation and delta angle
            TurningRadius = Self.carLength/sin(SteerAngle);
            DeltaAngle = DeltaDistance/TurningRadius;
            
            % Turning point calculation
            CarDirection = [cos(Self.currentAngle); sin(Self.currentAngle)];
            CarDirectionOrthogonal = [0 -1;1 0]*CarDirection;
            TurningPoint = Self.currentPosition + CarDirectionOrthogonal*TurningRadius;
            
            % Rotation matrix
            Rotation = [cos(DeltaAngle) -sin(DeltaAngle);sin(DeltaAngle) cos(DeltaAngle)];
            
            % Rotate
            NewPosition = Rotation*(CurrentPosition - TurningPoint) + TurningPoint;
            
            % Current angle calculation
            % Proof in etc/steering
            CurrentAngle = Self.currentAngle + DeltaAngle;
            Self.currentAngle = CurrentAngle;
            
            % Save new position
            Self.currentPosition = NewPosition;
        end
        
        % Inspect function
        function Inspect(Self)
            hold off;
            figure(2);
            
            subplot(3,1,1);
            plot(Self.time, Self.states(1,:));
            title 'State 1 (distance)';
            xlabel 'Time (s)';
            ylabel 'Distance (m)';
            grid on;
            
            subplot(3,1,2);
            plot(Self.time, Self.states(2,:));
            title 'State 2 (speed)';
            xlabel 'Time (s)';
            ylabel 'Speed (m/s)';
            grid on;
            
            subplot(3,1,3);
            plot(Self.time, Self.states(3,:));
            title 'State 3 (current)';
            xlabel 'Time (s)';
            ylabel 'Current (A)';
            grid on;
        end
    end
end

