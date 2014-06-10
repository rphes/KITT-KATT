classdef Simulator < handle
    properties (SetAccess = private)
        %% Init
        % Config
        DoDraw;
        DoDebug;

        % Wrapper objects
        ang;
        ssSteer;
        ssDrive;
        mapSteer;
        mapDrive;
        route;

        % Wrapper parameters
        Battery;
        ReferenceDistance;
        CarPosition;
        CurrentLocation;
        CurrentTrackedSpeed;
        CurrentTrackedDistance;
        SteerAngle;
        CarSpeed;
        CarAngle;
        SensorData;
        CurrentAngle
        PWMDrive;
        PWMSteer;
        CurrentDistance;
        DriveExcitation;
        CurrentWaypoint;

        % Obstacles
        obstacles;

        % Simulation parameters
        Delay;
        SimulationTime;
        InitialisationTime;

        % KITT model
        Model;

        % Localisation
        LocalisationDelay; % Number of measurements
        LocalisationNoise;

        % Obstacles, circles
        % These the first two parameters determine the position, the final
        % parameters determines the radius.
        
        %% Simulation
        % Location delay simulation initialisation
        LocalisationIndex;

        % Timers
        Timer;
        TimerStart;
    end

    methods
        % Constructor
        function Self = Simulator(InitialLocation, InitialAngle, DoDraw, DoDebug)
            Self.DoDraw = DoDraw;
            Self.DoDebug = DoDebug;
            
            % Initialize all objects
            Self.route = Route();
            Self.ang = Angle(InitialLocation, InitialAngle);
            Self.ssSteer = SsSteer();
            Self.ssDrive = SsDrive();
            Self.mapSteer = MapSteer();
            Self.mapDrive = MapDrive();
            
            Self.Battery = 0;
            Self.ReferenceDistance = 0;
            Self.CarPosition = [0; 0];
            Self.CurrentLocation = [0; 0];
            Self.CurrentTrackedSpeed = 0;
            Self.SteerAngle = 0;
            Self.CurrentWaypoint = [5;5];
            
            Self.obstacles = Obstacles([
                -2 2 1;
                3 3 1;
                -3 -3 2;
                6 -7 1.5
            ]);
            if Self.DoDraw ~= 0
                Self.obstacles.PrepareDraw();
            end
            
            Self.Delay = 0.15;
            Self.SimulationTime = 60*4;
            Self.InitialisationTime = .5;
            
            Self.Model = KITT();
            
            Self.LocalisationDelay = 1;
            Self.LocalisationNoise = 0.04;
            
            Self.LocalisationIndex = 0;

            % Timers
            Self.Timer = tic;
            Self.TimerStart = tic;
        end
        
        function Ret = Loop(Self)
            if toc(Self.TimerStart) < Self.SimulationTime
                Ret = 0; 
            end
            
            %% Pre
            % Check for localization
            DoObserve = 0;
            if Self.LocalisationIndex == Self.LocalisationDelay
                Self.LocalisationIndex = 0;

                % Generate noise
                Noise = [0;0];
                [Noise(1),Noise(2)] = pol2cart(rand(1,1)*2*pi,abs(randn(1,1)*Self.LocalisationNoise));

                % Update location
                Self.CurrentLocation = Self.CarPosition + Noise;
                DoObserve = 1;
            else
                Self.LocalisationIndex = Self.LocalisationIndex + 1;
            end

            % Sensor data
            Self.SensorData = Self.Model.GenerateSensorData(Self.obstacles);

            %% Simulation
            % Global variables set by C#
            global waypoint

            % Global variables to set
            global loc_x
            global loc_y
            global angle
            global speed
            global pwm_steer
            global pwm_drive
            
            Self.CurrentWaypoint = waypoint';

            % Determine current angle
            [Self.CurrentAngle] = Self.ang.DetermineAngle(Self.CurrentLocation);

            % Process route
            [Self.CurrentDistance, ReferenceAngle] = Self.route.DetermineRoute(Self.CurrentLocation, Self.CurrentAngle, Self.CurrentWaypoint, Self.SensorData);

            % Call controllers
            [Self.DriveExcitation, Self.CurrentTrackedSpeed, Self.CurrentTrackedDistance] = Self.ssDrive.Iterate(Self.CurrentDistance, Self.ReferenceDistance, Self.Battery, DoObserve);
            [SteerExcitation] = Self.ssSteer.Iterate(Self.CurrentAngle, ReferenceAngle, Self.Battery);

            % Excitation mapping
            [Self.PWMDrive] = Self.mapDrive.Map(Self.DriveExcitation, Self.CurrentAngle);
            [Self.PWMSteer] = Self.mapSteer.Map(SteerExcitation);

            % Initialisation
            if toc(Self.TimerStart) < Self.InitialisationTime
                Self.PWMDrive = 150;
                Self.PWMSteer = 0;
            end

            % Set
            loc_x = Self.CurrentLocation(1);
            loc_y = Self.CurrentLocation(2);
            angle = Self.CurrentAngle;
            speed = Self.CurrentTrackedSpeed;
            pwm_steer = Self.PWMSteer;
            pwm_drive = Self.PWMDrive;

            %% Update KITT
            [Self.CarPosition, Self.CarSpeed, Self.CarAngle] = Self.Model.Iterate(Self.PWMDrive, Self.PWMSteer);
            
            %% Visualise
            if Self.DoDraw ~= 0
                Visualise(Self);
            end
            
            %% Extended debug visualisation
            if Self.DoDebug ~= 0
                debug;
            end
            
            Ret = 1;
        end
        
        function Visualise(Self)
            figure(10);
            % Draw KITT shizzle
            plot(Self.CarPosition(1), Self.CarPosition(2), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
            hold on;
            plot([Self.CurrentLocation(1) Self.CurrentLocation(1)+CarDirection(1)],[Self.CurrentLocation(2) Self.CurrentLocation(2)+CarDirection(2)],'-r');
            plot([Self.CurrentLocation(1) Self.CurrentLocation(1)+CarReferenceDirection(1)],[Self.CurrentLocation(2) Self.CurrentLocation(2)+CarReferenceDirection(2)],'-b');
            plot(Self.CurrentWaypoint(1), Self.CurrentWaypoint(2), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');

            % Draw obstacles
            Self.obstacles.Draw();

            xlabel 'x (m)';
            ylabel 'y (m)';
            xlim([-10 10]);
            ylim([-10 10]);
            title 'Controller test';
            grid on;

            clc;
            display 'BEUNED KITT SIMULATOR';
            display '---------------------';
            display(['Time:                  ' num2str(round(toc(Self.TimerStart)*100)/100) '/' num2str(round(100*Self.SimulationTime)/100) ' s']);
            display(['State 1 (distance):    ' num2str(round(Self.CurrentTrackedDistance*100)) ' cm']);
            display(['State 2 (speed):       ' num2str(round(abs(Self.CurrentTrackedSpeed)*100)) ' cm/s']);
            display ' ';
            display(['Current distance:      ' num2str(round(Self.CurrentDistance*100)) ' cm']);
            display(['Current speed:         ' num2str(round(Self.CarSpeed*100)) ' cm']);
            display ' ';
            display(['Actual angle:          ' num2str(round(mod(Self.CarAngle,2*pi)*180/pi)) ' deg']);
            display(['Tracked angle:         ' num2str(round(mod(Self.CurrentAngle,2*pi)*180/pi)) ' deg']);
            display ' ';
            display(['Drive PWM:             ' num2str(Self.PWMDrive)]);
            display(['Drive Excitation:      ' num2str(Self.DriveExcitation)]);
            display(['Steer PWM:             ' num2str(Self.PWMSteer)]);
            display ' ';
            if DoObserve
                display 'Observation:           yes';
            else
                display 'Observation:           no';
            end
            display ' ';
            display(['Sensor left distance:  ' num2str(round(Self.SensorData(1)*100)) ' cm']);
            display(['Sensor right distance: ' num2str(round(Self.SensorData(2)*100)) ' cm']);
            if Self.CurrentDistance < 0
                display 'Overshoot:           yes';
            else
                display 'Overshoot:           no';
            end
        end
    end
end