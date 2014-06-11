%% Init
% Clear
clearvars -except DeconvolutionMatrix RecordData TDOASim PaWavSim

% Clear simulation defined classes
clear TDOA

% Fix path
addpath(genpath('.'));

% Simulation paths
if exist('PaWavSim','var') && (PaWavSim == 1)
	global paWavSimTic;
    paWavSimTic = tic;
    rmpath('./pa-wav');
else
    rmpath('./pa-wav-sim');
end
if exist('TDOASim','var') && (TDOASim == 1)
    rmpath('./tdoa');
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
    ProcessingTime = 0.1;
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