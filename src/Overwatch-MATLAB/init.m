% Fix path
addpath(genpath('.'));

% Create wrapper object with initial location
InitialLocation = [0 0];
InitialAngle = 0;
MicrophoneLocations = [];
wrapper = Wrapper(InitialLocation, InitialAngle, MicrophoneLocations);

global figure; % figure handle
global subplotAxes; % subplot axis handles
global subplotLines; % subplot line handles

figure = figure();
subplotAxes = cell(3,2); % 3 subplots horizontally, 2 vertically
subplotLines = cell(3,2,2) % 2 plots per subplot
i = 1;
for subplotX = 1:3
	for subplotY = 1:2
	% subplot left top: waypoint_x, loc_x
	% subplot middle top: waypoint_y, loc_y
	% subplot right top: angle, ref_angle
	% subplot left bottom: sensor_l, sensor_r
	% subplot middle bottom: pwm_steer, pwm_drive
	% subplot right bottom: speed, CurrentDistance
	subplotAxes{subplotX, subplotY} = subplot(3, 2, i)
	i = i + 1;
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