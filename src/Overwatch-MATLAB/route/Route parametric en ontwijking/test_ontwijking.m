clc;    clear all;

Currentlocation = [11 11];
Currentangle = pi/2; 
Waypoints = [0 0];
Sensors = [0 0];
ikke = Route;

[CurrentDistance, ReferenceAngle] = DetermineRoute(ikke, Currentlocation, Currentangle, Waypoints, Sensors);

Temp_waypoint = ikke.propTemp_waypoint
Circle_point = ikke.propCirclepoint
r_point = ikke.propr_point2;


vector1 = Currentlocation - r_point;
vector2 = Circle_point - r_point;

costheta = dot(vector1,vector2)/(norm(vector1)*norm(vector2));
theta = acos(costheta)*180/pi