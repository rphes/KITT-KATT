clear all

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

% Waypoints
Waypoints = [[5;-5] [1;1] [-5;5]];

% Simulation parameters
Delay = 0.15;
SimulationTime = 20;
LocationDelay = 0.15;

% KITT model
Model = KITT();

%% Simulation
% Location delay simulation initialisation
LocationIndexIterations = ceil(Delay/LocationDelay);
LocationIndex = 0;

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
    LocationIndex = LocationIndex + 1;
    if mod(LocationIndex, LocationIndexIterations) == 0
        CurrentLocation = CarPosition; % Noise?
        DoObserve = 1;
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
    % Determine current angle
    CurrentAngle = ang.DetermineAngle(CurrentLocation);

    % Process route
    [CurrentDistance, ReferenceAngle] = route.DetermineRoute(CurrentLocation, CurrentAngle, Waypoint, SensorData);

    % Call controllers
    [DriveExcitation, CurrentTrackedSpeed, CurrentTrackedDistance] = ssDrive.Iterate(CurrentDistance, ReferenceDistance, Battery, DoObserve);
    [SteerExcitation] = ssSteer.Iterate(CurrentAngle, ReferenceAngle, Battery);

    % Excitation mapping
    [PWMDrive] = mapDrive.Map(DriveExcitation, CurrentAngle);
    [PWMSteer] = mapSteer.Map(SteerExcitation);
    
    %% Update KITT
    [CarPosition, CarSpeed, CarAngle] = Model.Iterate(PWMDrive, PWMSteer);
    
    %% Information display
    CarReferenceDirection = [cos(ReferenceAngle); sin(ReferenceAngle)];
    CarDirection = [cos(CarAngle); sin(CarAngle)];
    figure(1);
    
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
    
    %% Delay
    pause(Delay);
end