%% Init
% Clear simulation defined classes
clear TDOA

% Fix path
addpath(genpath('.'));

% Simulation paths
if exist('PaWavSim','var')
    rmpath('./pa-wav');
else
    rmpath('./pa-wav-sim');
end
if exist('TDOASim','var')
    rmpath('./tdoa');
else
    rmpath('./tdoa-sim');
end

% Create wrapper object with initial location
InitialLocation = [0; 0];
InitialAngle = 0;
wrapper = Wrapper(InitialLocation, InitialAngle);

%% Globals
% Define global variables for communication
% Global variables set by C#
global sensor_l
global sensor_r
global battery
global waypoint

% Global variables to set
global loc_x
global loc_y
global angle
global speed
global pwm_steer
global pwm_drive