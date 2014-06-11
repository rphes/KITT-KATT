clearvars -except DeconvolutionMatrix RecordData
TDOASim = 1;
generate;
init;

%% Set globals
global waypoint
waypoint = [0; 0];

global sensor_l
global sensor_r
sensor_l = 3;
sensor_r = 3;

global battery
battery = 20;

global pwm_drive
global pwm_steer

%% Simulate that shit
ProcessingTime = 0.35;
InitialisationTime = 0.5;
SimTime = 120;

% Init
global tdoaSimLocation
tdoaSimLocation = [0; 0];

% Obstacles
obstacles = Obstacles([
    3 3 1
]);

% Waypoints
Waypoints = [[5; 7] [1; 3] [6; 6]];
CurrentWaypoint = 1;
WaypointThreshold = 0.25;

% KITT model
Model = KITT();

% Start
SimTimer = tic;

while toc(SimTimer) < SimTime
    % Determine waypoint
    WaypointDistance = norm(tdoaSimLocation - Waypoints(:,CurrentWaypoint));
    if WaypointDistance < WaypointThreshold
        if CurrentWaypoint < size(Waypoints,2)
            CurrentWaypoint = CurrentWaypoint+1;
        end
    end
    waypoint = Waypoints(:,CurrentWaypoint);
    
    % Get sensor data
    SensorData = Model.GenerateSensorData(obstacles);
    sensor_l = SensorData(1);
    sensor_r = SensorData(2);
    
    % Call loop
    loopLocalize();
    loopControl();
    
    % Retrieve feedback
    PWMDrive = pwm_drive;
    PWMSteer = pwm_steer;
    
    % Initialisation time check
    if toc(SimTimer) < InitialisationTime
        PWMDrive = 150;
        PWMSteer = 0;
    end
    
    % Model
    [CarPosition, CarSpeed, CarAngle] = Model.Iterate(PWMDrive, PWMSteer);
    tdoaSimLocation = CarPosition; % Update location
    
    pause(ProcessingTime);
end