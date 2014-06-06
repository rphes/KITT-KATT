% Fix path
addpath(genpath('.'));

% Create wrapper object with initial location
InitialLocation = [0 0];
InitialAngle = 0;
MicrophoneLocations = [];
wrapper = Wrapper(InitialLocation, InitialAngle, MicrophoneLocations);

global fig;
global subplots;
fig = figure();
for i = 1:4
	% subplot left top: waypoint_x, loc_x
	% subplot right top: waypoint_y, loc_y
	% subplot left bottom: sensor_l, sensor_r
	% subplot 
	subplots(i) = subplots(2, 2, i);
end


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