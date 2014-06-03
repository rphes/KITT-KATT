% Fix path
addpath(genpath('.'));

% Create wrapper object with initial location
InitialLocation = [0 0];
InitialAngle = 0;
MicrophoneLocations = [];
wrapper = Wrapper(InitialLocation, InitialAngle, MicrophoneLocations);

% Create anonymous function for C# to call
loop = @() wrapper.Loop();

% Define global variables for communication
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