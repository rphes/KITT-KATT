classdef SsDrive
    properties (SetAccess = private)
        % Time keeping
        currentTime
        
        % State tracking
        currentState
        
        % Model
        A
        B
        C
        L
        K
    end
    
    methods
        % Constructor
        function Self = SsDrive()
            % State-space model calculation
            Self.A = [
                0 1;
                0 -Configuration.DriveRollingCoefficient/Configuration.DriveCarWeight
            ];
            Self.B = [
                0;
                1/Configuration.DriveCarWeight
            ];
            Self.C = [1 0];

            % Observer feedback matrix
            Self.L = acker(Self.A', Self.C', [...
                Configuration.DriveObserverPoles
                Configuration.DriveObserverPoles
            ])';

            % Stabilization matrix
            Self.K = acker(Self.A, Self.B, [...
                Configuration.DriveCompensatorPoles
                Configuration.DriveCompensatorPoles
            ]);
            
            % Start tracking time
            self.currentTime = tic;
            
            % State initialization
            self.currentState = [0; 0];
        end
        
        % Iteration
        function [DriveExcitation, CurrentTrackedSpeed, CurrentTrackedDistance] = Iterate(Self, CurrentDistance, ReferenceDistance, ~, DoObserve) % BatteryVoltage
            % Time tracking
            dt = toc(Self.currentTime);
            Self.currentTime = tic;
            
            % State calculation by Euler
            N = 1000;
            NewState = Self.currentState;
            ReferenceState = [ReferenceDistance; 0]; % Not moving at a distance
            
            for i = 1:N
                r = (Self.A - Self.B*Self.K - DoObserve*Self.L*Self.C)*NewState+ ... System feedback
                    Self.B*Self.K*ReferenceState+ ... Compensation
                    DoObserve*Self.L*CurrentDistance; % Observation
                NewState = NewState + dt*r/N;
            end
            
            % Save state and stuff
            Self.currentState = NewState;
            CurrentTrackedDistance = Self.currentState(1);
            CurrentTrackedSpeed = Self.currentState(2);
            
            % Calculate Excitation
            DriveExcitation = Self.K*(Self.currentState - ReferenceState);
        end
    end
end

