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

% Debug globals
global debugStateDistance
global debugStateSpeed
global debugReferenceAngle

CarDirection = [cos(angle); sin(angle)];
CarReference = [cos(debugReferenceAngle); sin(debugReferenceAngle)];

figure(10);
% Draw shizz
plot(loc_x, loc_y, 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
hold on;
plot([loc_x loc_x+CarDirection(1)],[loc_y loc_y+CarDirection(2)],'-r');
plot([loc_x loc_x+CarReference(1)],[loc_y loc_y+CarReference(2)],'-b');
plot(waypoint(1), waypoint(2), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'blue');
xlabel 'x (m)';
ylabel 'y (m)';
xlim([-1 8]);
ylim([-1 8]);
title 'Field';
grid on;

clc;
display 'DEBUG INFO';
display '---------------------';
display(['Determined position:   (' num2str(round(loc_x*100)/100) ' m, ' num2str(round(loc_y*100)/100) ' m)']);
display ' ';
display(['Tracked angle:         ' num2str(round(mod(angle,2*pi)*180/pi)) ' deg']);
display(['Reference angle:       ' num2str(round(mod(debugReferenceAngle,2*pi)*180/pi)) ' deg']);
display ' ';
display(['State 1 (distance):    ' num2str(round(debugStateDistance*100)) ' cm/s']);
display(['State 2 (speed):       ' num2str(round(debugStateSpeed*100)) ' cm/s']);
display ' ';
display(['Drive PWM:             ' num2str(pwm_drive)]);
display(['Steer PWM:             ' num2str(pwm_steer)]);
display ' ';
display(['Sensor left distance:  ' num2str(round(sensor_l*100)) ' cm']);
display(['Sensor right distance: ' num2str(round(sensor_r*100)) ' cm']);
display ' ';
display(['Battery:               ' num2str(round(battery*100)/100) ' V']);