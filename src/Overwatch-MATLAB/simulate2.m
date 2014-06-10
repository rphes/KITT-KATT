% Set globals
global waypoint
waypoint = [1; 1];

global sensor_l
global sensor_r
sensor_l = 3;
sensor_r = 3;

global battery
battery = 20;

% Simulate dat shit
ProcessingTime = 0.1;
SimTime = 19;

global paWavSimTic
paWavSimTic = tic;
SimTimer = tic;

while toc(SimTimer) < SimTime
    loop();
    pause(0.1);
end