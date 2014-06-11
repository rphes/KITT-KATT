clearvars -except DeconvolutionMatrix RecordData
TDOASimPath = 1;
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

%% Simulate that shit
ProcessingTime = 0.25;
InitialisationTime = 0.5;
SimTime = 120;

% Init
global tdoaSimLocation
tdoaSimLocation = [0; 0];

% Obstacles
obstacles = Obstacles([
    -2 2 1;
    3 3 1;
    -3 -3 2;
    6 -7 1.5
]);
obstacles.PrepareDraw();

% Waypoints
Waypoints = [[7; 7] [-5; 0] [5; 2]];
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
    loop();
    global pwm_drive
    global pwm_steer
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
    
    % Information display
    CarDirection = [cos(CarAngle); sin(CarAngle)];
    
    figure(10);
    % Draw KITT shizzle
    plot(CarPosition(1), CarPosition(2), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
    hold on;
    plot([CarPosition(1) CarPosition(1)+CarDirection(1)],[CarPosition(2) CarPosition(2)+CarDirection(2)],'-r');
    plot(waypoint(1), waypoint(2), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
    % Draw obstacles
    obstacles.Draw();
    hold off;
    xlabel 'x (m)';
    ylabel 'y (m)';
    xlim([-10 10]);
    ylim([-10 10]);
    title 'Controller test';
    grid on;

    clc;
    display 'BEUNED KITT SIMULATOR';
    display '---------------------';
    display(['Time:                  ' num2str(round(toc(SimTimer)*100)/100) '/' num2str(round(100*SimTime)/100) ' s']);
    display ' ';
    display(['Actual angle:          ' num2str(round(mod(CarAngle,2*pi)*180/pi)) ' deg']);
    display(['Distance to waypoint:  ' num2str(round(WaypointDistance*100)) ' cm']);
    display ' ';
    display(['Drive PWM:             ' num2str(PWMDrive)]);
    display(['Steer PWM:             ' num2str(PWMSteer)]);
    display ' ';
    display(['Sensor left distance:  ' num2str(round(SensorData(1)*100)) ' cm']);
    display(['Sensor right distance: ' num2str(round(SensorData(2)*100)) ' cm']);
    
    pause(ProcessingTime);
end