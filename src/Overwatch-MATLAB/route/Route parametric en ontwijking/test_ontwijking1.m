for dr = 1:6
figure(dr)
clc;

subplot(1, 1, dr);
Currentlocation = [12 10];
Waypoints = [11 10]; Currentangle = dr*pi/2; s = Route;
Sensor = [10, 0];


%Ik heb een circle (x-p)^2+(y-q)^2 = r^2
cx = Currentlocation(1); cy = Currentlocation(2); r = 7; x_begin = 3;
a_maximum = 2*pi;
delta_a = 2*pi/20;

for j = 1:20
    a = a_maximum - j*delta_a;
    x = cx + r*cos(a);
    y = cy + r*sin(a);
    Currentlocation = [x, y];
    
    [distance, Ref_angle] = DetermineRoute(s, Currentlocation, Currentangle, Waypoints, Sensor);
    plot(Currentlocation(1), Currentlocation(2), 'o', s.propr_point(1), s.propr_point(2), '+', s.propTemp_waypoint(1), s.propTemp_waypoint(2), 'b*', s.propcircle_x, s.propcircle_y, 'b', s.proplijn_x,  s.proplijn_y, 'g', s.propkop_x, s.propkop_y, 'r');
    hold on;
    axis([0, 20, 0 20])
    
end
end