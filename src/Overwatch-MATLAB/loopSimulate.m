% Determine waypoint
global waypoint

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

% Model
[CarPosition, CarSpeed, CarAngle] = Model.Iterate(PWMDrive, PWMSteer);
tdoaSimLocation = CarPosition; % Update location

pause(ProcessingTime);