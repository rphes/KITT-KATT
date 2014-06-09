%% Init
clear all;
% init;

% Config
DoDraw = 1;
DoDebug = 0;
DoAdditional = 0;

% Wrapper objects
InitialLocation = [0; 0];
InitialAngle = 0;
ang = Angle(InitialLocation, InitialAngle);
ssSteer = SsSteer();
ssDrive = SsDrive();
mapSteer = MapSteer();
mapDrive = MapDrive();
route = Route();

% Wrapper parameters
Battery = 0;
ReferenceDistance = 0;
CarPosition = [0; 0];
CurrentLocation = [0; 0];
CurrentTrackedSpeed = 0;
SteerAngle = 0;

% Waypoints
Waypoints = [[5;5] [9;1] [1;8]];

% Simulation parameters
Delay = 0.15;
SimulationTime = 60;
InitialisationTime = 2;

% KITT model
Model = KITT();

% Localisation
LocalisationDelay = 3; % Number of measurements
LocalisationNoise = 0.04;


%% Simulation
% Location delay simulation initialisation
LocalisationIndex = 0;

% Waypoint initalisation
CurrentWaypointIndex = 1;
Waypoint = Waypoints(:, CurrentWaypointIndex);

% Timers
Timer = tic;
TimerStart = tic;

hold off;

while toc(TimerStart) < SimulationTime
    %% Pre
    % Check for localization
    DoObserve = 0;
    if LocalisationIndex == LocalisationDelay
        LocalisationIndex = 0;
        
        % Generate noise
        Noise = [0;0];
        [Noise(1),Noise(2)] = pol2cart(rand(1,1)*2*pi,abs(randn(1,1)*LocalisationNoise));
        
        % Update location
        CurrentLocation = CarPosition + Noise;
        DoObserve = 1;
    else
        LocalisationIndex = LocalisationIndex + 1;
    end
    
    % Sensor data
    SensorData = [3 3];
    
    % Check if waypoint is reached and another waypoint is available
    if (norm(CarPosition-Waypoint) < 0.1) && (CurrentWaypointIndex < size(Waypoints,2))
        CurrentWaypointIndex = CurrentWaypointIndex+1;
    end
    
    % Determine current waypoint
    Waypoint = Waypoints(:, CurrentWaypointIndex);
    
    %% Simulation
    % Global variables set by C#
    global sensor_l
    global sensor_r
    global battery
    global waypoints

    % Global variables to set
    global loc_x
    global loc_y
    global angle
    global speed
    global pwm_steer
    global pwm_drive
    
    % Determine current angle
    [CurrentAngle] = ang.DetermineAngle(CurrentLocation);
    
    % Process route
    [CurrentDistance, ReferenceAngle] = route.DetermineRoute(CurrentLocation, CurrentAngle, Waypoint, SensorData);

    % Call controllers
    [DriveExcitation, CurrentTrackedSpeed, CurrentTrackedDistance] = ssDrive.Iterate(CurrentDistance, ReferenceDistance, Battery, DoObserve);
    [SteerExcitation] = ssSteer.Iterate(CurrentAngle, ReferenceAngle, Battery);

    % Excitation mapping
    [PWMDrive] = mapDrive.Map(DriveExcitation, CurrentAngle);
    [PWMSteer] = mapSteer.Map(SteerExcitation);
    
    % Initialisation
    if toc(TimerStart) < InitialisationTime
        PWMDrive = 150;
        PWMSteer = 0;
    end
    
    % Set
    loc_x = CurrentLocation(1);
    loc_y = CurrentLocation(2);
    angle = CurrentAngle;
    speed = CurrentTrackedSpeed;
    pwm_steer = PWMSteer;
    pwm_drive = PWMDrive;
    waypoints = Waypoints;
    battery = 20;
    sensor_l = 0;
    sensor_r = 0;
    
    %% Update KITT
    [CarPosition, CarSpeed, CarAngle] = Model.Iterate(PWMDrive, PWMSteer);
    
    %% Information display
    CarReferenceDirection = [cos(ReferenceAngle); sin(ReferenceAngle)];
    CarDirection = [cos(CarAngle); sin(CarAngle)];
    
    if DoDraw
        figure(10);
        plot(CarPosition(1), CarPosition(2), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
        hold on;
        plot([CurrentLocation(1) CurrentLocation(1)+CarDirection(1)],[CurrentLocation(2) CurrentLocation(2)+CarDirection(2)],'-r');
        plot([CurrentLocation(1) CurrentLocation(1)+CarReferenceDirection(1)],[CurrentLocation(2) CurrentLocation(2)+CarReferenceDirection(2)],'-b');
        plot(Waypoint(1), Waypoint(2), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
        xlabel 'x (m)';
        ylabel 'y (m)';
        xlim([-10 10]);
        ylim([-10 10]);
        title 'Controller test';
        grid on;
    
        clc;
        display 'BEUNED KITT SIMULATOR';
        display '---------------------';
        display(['Time:               ' num2str(round(toc(TimerStart)*100)/100) '/' num2str(round(100*SimulationTime)/100) ' s']);
        display(['State 1 (distance): ' num2str(round(CurrentTrackedDistance*100)) ' cm']);
        display(['State 2 (speed):    ' num2str(round(abs(CurrentTrackedSpeed)*100)) ' cm/s']);
        display ' ';
        display(['Current distance:   ' num2str(round(CurrentDistance*100)) ' cm']);
        display(['Current speed:      ' num2str(round(CarSpeed*100)) ' cm']);
        display ' ';
        display(['Actual angle:       ' num2str(round(mod(CarAngle,2*pi)*180/pi)) ' deg']);
        display(['Tracked angle:      ' num2str(round(mod(CurrentAngle,2*pi)*180/pi)) ' deg']);
        display ' ';
        display(['Drive PWM:          ' num2str(PWMDrive)]);
        display(['Steer PWM:          ' num2str(PWMSteer)]);
        display ' ';
        if DoObserve
            display 'Observation:        yes';
        else
            display 'Observation:        no';
        end
    end
    
    if DoDebug
        debug;
    end
    
    %% Pause
    pause(Delay);
end