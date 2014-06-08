Currentlocation = [16 6];
Currentangle = 3*pi/4; s = Route;
beweeg = [cos(Currentangle) sin(Currentangle)];
Waypoints = Currentlocation + 3*beweeg;
Sensor = [10, 0];
Steering = 150;

[distance, Ref_angle] = DetermineRoute(s, Currentlocation, Currentangle, Waypoints, Sensor, Steering);
Object = s.propObjectlocation;
plot(Currentlocation(1), Currentlocation(2), 'o', Object(1), Object(2), 's', s.propTemp_waypoint(1), s.propTemp_waypoint(2), 'b*', s.propcircle_x, s.propcircle_y, 'b', s.proplijn_x,  s.proplijn_y, 'g', s.propkop_x, s.propkop_y, 'r');
hold on;
axis([0, 20, 0 20])

begin = s.propbeginpunt;
eind = s.propeindpunt; 
v2 = eind - begin;
v1 = [1 0];

%Bereken de hoek v2 tegenover v1 met de klok mee.
ang = atan2(v1(1)*v2(2)-v2(1)*v1(2),v1(1)*v2(1)+v1(2)*v2(2));  
Angle = mod(-180/pi * ang, 360);
Currentangle = Angle*pi/180;

Currentlocation = s.propTemp_waypoint;

Sensor = [10 10];
[distance, Ref_angle] = DetermineRoute(s, Currentlocation, Currentangle, Waypoints, Sensor, Steering);
plot(Currentlocation(1), Currentlocation(2), 'o', Waypoints(1), Waypoints(2), 'x', s.propTemp_waypoint(1), s.propTemp_waypoint(2), 'b*', s.propcircle_x, s.propcircle_y, 'b', s.proplijn_x,  s.proplijn_y, 'g', s.propkop_x, s.propkop_y, 'r');
hold off;
axis([0, 20, 0 20])