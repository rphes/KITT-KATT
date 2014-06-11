classdef SsDrive < handle
    properties (SetAccess = private)
        % Time keeping
        currentTime
        
        % State-space model parameters
        carMass = 1;             % Car mass (carefulness)
        carResistance = 0.12;    % Car resistance (lack of carefulness)
        motorInductance = 0.020; % Self-inductance
        motorConstant = 0.5;     % Motor constant
        motorResistance = 0.05;  % Motor resistance (current oscillation)
        wheelRadius = 0.15;      % Wheel radius
        motorGearRatio = 20;     % Gear ratio <!--- IMPORTANT ---!> (attack)
        
        % State-space model
        currentState = [0; 0; 0];
        A
        B
        C
        D
        L
        K
        
        % State tracking
        states
        statesReference
        sensorDistance
        excitation
        time
        timerBegin
    end
    
    methods
        % Constructor
        function Self = SsDrive()
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

            % Observer feedback matrix
            Self.L = acker(Self.A', Self.C', [...
                Configuration.DriveObserverPoles
                Configuration.DriveObserverPoles
                Configuration.DriveObserverPoles
            ])';

            % Stabilization matrix
            Self.K = acker(Self.A, Self.B, [...
                Configuration.DriveCompensatorPoles
                Configuration.DriveCompensatorPoles
                Configuration.DriveCompensatorPoles
            ]);
            
            % Start tracking time
            Self.currentTime = tic;
            Self.timerBegin = tic;
        end
        
        % Iteration
        function [DriveExcitation, CurrentTrackedSpeed, CurrentTrackedDistance] = Iterate(Self, CurrentDistance, ReferenceDistance, ~, DoObserve) % BatteryVoltage
            % Time tracking
            Dt = toc(Self.currentTime);
            Self.currentTime = tic;
            
            % State calculation by Euler
            N = 100;
            NewState = Self.currentState;
            ReferenceState = [ReferenceDistance; 0; 0]; % Not moving at a distance
            
            for i = 1:N
                r = (Self.A - Self.B*Self.K - DoObserve*Self.L*Self.C)*NewState+ ... System feedback
                    Self.B*Self.K*ReferenceState+ ... Compensation
                    DoObserve*Self.L*CurrentDistance; % Observation
                NewState = NewState + Dt*r/N;
            end
            
            % Save state and stuff
            Self.currentState = NewState;
            CurrentTrackedDistance = Self.currentState(1);
            CurrentTrackedSpeed = Self.currentState(2);
            
            % Calculate Excitation
            DriveExcitation = Self.K*(Self.currentState - ReferenceState);
            
            % Track
            Self.states = [Self.states NewState];
            Self.statesReference = [Self.statesReference ReferenceState];
            Self.time = [Self.time toc(Self.timerBegin)];
            Self.sensorDistance = [Self.sensorDistance CurrentDistance];
            Self.excitation = [Self.excitation DriveExcitation];
            
            % Debug
            global debugStateDistance
            global debugStateSpeed
            debugStateDistance = NewState(1);
            debugStateSpeed = NewState(2);
        end
        
        % Inspect function
        function Inspect(Self)
            hold off;
            figure(3);
            
            subplot(2,2,1);
            plot(Self.time, Self.states(1,:), Self.time, Self.statesReference(1,:), Self.time, Self.sensorDistance);
            title 'State 1 (distance)';
            xlabel 'Time (s)';
            ylabel 'Distance (m)';
            legend({'State','Reference','Input (measured)'});
            grid on;
            
            subplot(2,2,2);
            plot(Self.time, Self.states(2,:), Self.time, Self.statesReference(2,:));
            title 'State 2 (speed)';
            xlabel 'Time (s)';
            ylabel 'Speed (m/s)';
            legend({'State','Reference'});
            grid on;
            
            subplot(2,2,3);
            plot(Self.time, Self.states(3,:), Self.time, Self.statesReference(3,:));
            title 'State 3 (current)';
            xlabel 'Time (s)';
            ylabel 'Current (A)';
            legend({'State','Reference'});
            grid on;
            
            subplot(2,2,4);
            plot(Self.time, Self.excitation);
            title 'Excitation';
            xlabel 'Time (s)';
            ylabel 'Excitation';
            grid on;
        end
    end
end

