clc;

display 'DEBUG';
display '--------------';
display(['Current position: (' num2str(round(100*loc_x)) ',' num2str(round(100*loc_y)) ') cm']);
display(['Current angle: ' num2str(round(angle*180/pi)) ' degrees']);
display(['Current speed: ' num2str(round(100*speed)) ' cm/s']);
display ' ';

global subplotAxes % subplot axis handles
global subplotLines % subplot line handles
global subplotTimer % subplot timer
global waypoint

t = toc(subplotTimer);

%% Top left
addLinePoint(subplotLines{1,1}(1), loc_x, loc_y);
for i = 1:size(waypoint,2)
    addLinePoint(subplotLines{1,1}(2), waypoint(1,i), waypoint(2,i));
end

%% Top left center
addLinePoint(subplotLines{1,2}(1), t, loc_x);
addLinePoint(subplotLines{1,2}(2), t, waypoint(1,1));
shiftAxis(subplotAxes{1,2}, t);

%% Top right center
addLinePoint(subplotLines{1,3}(1), t, loc_y);
addLinePoint(subplotLines{1,3}(2), t, waypoint(2,1));
shiftAxis(subplotAxes{1,3}, t);

%% Top right
addLinePoint(subplotLines{1,4}(1), t, angle);
addLinePoint(subplotLines{1,4}(2), t, ReferenceAngle);
shiftAxis(subplotAxes{1,4}, t);

%% Bottom left
addLinePoint(subplotLines{2,1}(1), t, sensor_l);
addLinePoint(subplotLines{2,1}(2), t, sensor_r);
shiftAxis(subplotAxes{2,1}, t);

%% Bottom left center
addLinePoint(subplotLines{2,2}(1), t, pwm_steer);
addLinePoint(subplotLines{2,2}(2), t, pwm_drive);
shiftAxis(subplotAxes{2,2}, t);

%% Bottom right center
addLinePoint(subplotLines{2,3}(1), t, speed);
addLinePoint(subplotLines{2,3}(2), t, CurrentDistance);
shiftAxis(subplotAxes{2,3}, t);

%% Bottom right
addLinePoint(subplotLines{2,4}(1), t, battery);
shiftAxis(subplotAxes{2,4}, t);

%% Additional variables
Self.currentLocation
