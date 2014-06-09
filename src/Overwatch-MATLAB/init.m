clear all

%% Init
% Fix path
addpath(genpath('.'));

% Create wrapper object with initial location
InitialLocation = [0 0];
InitialAngle = 0;
MicrophoneLocations = [];
%wrapper = Wrapper(InitialLocation, InitialAngle, MicrophoneLocations);

%% Debug
% Create and initialise handles for the figure, its subplots and their lines
close all;
global subplotAxes % subplot axis handles
global subplotLines % subplot line handles
global subplotTimer % subplot timer

subplotAxes = cell(2,4); % 3 subplots horizontally, 2 vertically
subplotLines = cell(2,4);
i = 1;
for subplotY = 1:2
	for subplotX = 1:4
		% subplot top left: loc_x, loc_y
        % subplot top left center: waypoint_x, loc_x
		% subplot top right center: waypoint_y, loc_y
		% subplot top right: angle, ref_angle
		% subplot bottom left: sensor_l, sensor_r
		% subplot bottom left center: pwm_steer, pwm_drive
		% subplot bottom right center: speed, CurrentDistance
        % subplot bottom right: battery
		subplotAxes{subplotY, subplotX} = ...
            subaxis(2, 4, i, ...
            'SpacingHoriz', 0.03, ...
            'SpacingVert', 0.08, ...
            'Padding', 0, ...
            'MT', 0.03, ...
            'MB', 0.05, ...
            'ML', 0.03, ...
            'MR', 0.01);
		subplotLines{subplotY, subplotX} = plot(0,0,0,0); % 2 lines per subplot
        grid on;
        
        switch i
            case 1
                subplotLines{subplotY, subplotX} = plot(0,0,'b',0,0,'ro');
                grid on;
                xlim([0 Configuration.XMax]);
                xlabel('X (m)');
                ylim([0 Configuration.YMax]);
                ylabel('Y (m)');
                title('Car trajectory');
                legend('Trajectory', 'Waypoints');
            case 2
                ylim([0 Configuration.XMax]);
                xlabel('time (s)');
                ylabel('X (m)');
                title('Car and waypoint X-coords');
                legend('Waypoint', 'Car');
            case 3
                ylim([0 Configuration.YMax]);
                xlabel('time (s)');
                ylabel('Y (m)');
                title('Car and waypoint Y-coords');
                legend('Waypoint', 'Car');
            case 4
                ylim([-pi pi]);
                xlabel('time (s)');
                ylabel('angle (rad)');
                title('Car angle and reference angle');
                legend('Angle', 'Reference angle');
            case 5
                ylim([0 3]);
                xlabel('time (s)');
                ylabel('distance (m)');
                title('Sensor distances');
                legend('Left', 'Right');
            case 6
                ylim([95 205]);
                xlabel('time (s)');
                ylabel('PWM');
                title('PWM drive and steer values');
                legend('Steer', 'Drive');
            case 7
                ylim([0 15]);
                xlabel('time (s)');
                ylabel('speed (m/s) / distance (m)');
                title('Speed and distance to target');
                legend('Speed', 'Distance');
            case 8
                subplotLines{subplotY, subplotX} = plot(0);
                grid on;
                xlim([0 Configuration.PlotTimeFrame]);
                ylim([0 21]);
                xlabel('time (s)');
                ylabel('voltage (V)');
                title('Battery voltage');
                legend('Battery voltage');
        end
        
        % Reset all plot data after handle has been created
        set(subplotLines{subplotY, subplotX}, 'XData', []);
        set(subplotLines{subplotY, subplotX}, 'YData', []);
        
		i = i + 1;
	end
end
subplotTimer = tic;

%% Globals
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