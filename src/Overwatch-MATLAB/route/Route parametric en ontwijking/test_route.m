figure(1)
clc; clear all;

subplot(2, 2, 1);
Currentlocation = [10 10]; Currentangle = pi/4; s = Route;
Sensor = [10, 10];


%Ik heb een circle (x-p)^2+(y-q)^2 = r^2
cx = Currentlocation(1); cy = Currentlocation(2); r = sqrt(5); x_begin = 3;
a_maximum = 2*pi;
delta_a = 2*pi/100;

for j = 1:100
    r = r*1.015;
    a = a_maximum - j*delta_a;
    x = cx + r*cos(a);
    y = cy + r*sin(a);
    Waypoints = [x, y];
    
    [distance, Ref_angle] = DetermineRoute(s, Currentlocation, Currentangle, Waypoints, Sensor);
    
    plot(Currentlocation(1), Currentlocation(2), 'o', s.propr_point(1), s.propr_point(2), '+', Waypoints(1), Waypoints(2), 'x', s.propcircle_x, s.propcircle_y, 'b', s.proplijn_x,  s.proplijn_y, 'g', s.propkop_x, s.propkop_y, 'r');
    hold on;
    axis([0, 20, 0 20])
    
end















clc; clear all;

subplot(2, 2, 2);
Currentlocation = [10 10]; Currentangle = 3*pi/4; s = Route;
Sensor = [10, 10];


%Ik heb een circle (x-p)^2+(y-q)^2 = r^2
cx = Currentlocation(1); cy = Currentlocation(2); r = sqrt(5); x_begin = 3;
a_maximum = 2*pi;
delta_a = 2*pi/100;

for j = 1:100
    r = r*1.015;
    a = a_maximum - j*delta_a;
    x = cx + r*cos(a);
    y = cy + r*sin(a);
    Waypoints = [x, y];
    
    [distance, Ref_angle] = DetermineRoute(s, Currentlocation, Currentangle, Waypoints, Sensor);
    
    plot(Currentlocation(1), Currentlocation(2), 'o', s.propr_point(1), s.propr_point(2), '+', Waypoints(1), Waypoints(2), 'x', s.propcircle_x, s.propcircle_y, 'b', s.proplijn_x,  s.proplijn_y, 'g', s.propkop_x, s.propkop_y, 'r');
    hold on;
    axis([0, 20, 0 20])
    
end















clc; clear all;

subplot(2, 2, 3);
Currentlocation = [10 10]; Currentangle = 5*pi/4; s = Route;
Sensor = [10, 10];


%Ik heb een circle (x-p)^2+(y-q)^2 = r^2
cx = Currentlocation(1); cy = Currentlocation(2); r = sqrt(5); x_begin = 3;
a_maximum = 2*pi;
delta_a = 2*pi/100;

for j = 1:100
    r = r*1.015;
    a = a_maximum - j*delta_a;
    x = cx + r*cos(a);
    y = cy + r*sin(a);
    Waypoints = [x, y];
    
    [distance, Ref_angle] = DetermineRoute(s, Currentlocation, Currentangle, Waypoints, Sensor);
    
    plot(Currentlocation(1), Currentlocation(2), 'o', s.propr_point(1), s.propr_point(2), '+', Waypoints(1), Waypoints(2), 'x', s.propcircle_x, s.propcircle_y, 'b', s.proplijn_x,  s.proplijn_y, 'g', s.propkop_x, s.propkop_y, 'r');
    hold on;
    axis([0, 20, 0 20])
    
end
















clc; clear all;

subplot(2, 2, 4);
Currentlocation = [10 10]; Currentangle = 7*pi/4; s = Route;
Sensor = [10, 10];


%Ik heb een circle (x-p)^2+(y-q)^2 = r^2
cx = Currentlocation(1); cy = Currentlocation(2); r = sqrt(5); x_begin = 3;
a_maximum = 2*pi;
delta_a = 2*pi/100;

for j = 1:100
    r = r*1.015;
    a = a_maximum - j*delta_a;
    x = cx + r*cos(a);
    y = cy + r*sin(a);
    Waypoints = [x, y];
    
    [distance, Ref_angle] = DetermineRoute(s, Currentlocation, Currentangle, Waypoints, Sensor);
    
    plot(Currentlocation(1), Currentlocation(2), 'o', s.propr_point(1), s.propr_point(2), '+', Waypoints(1), Waypoints(2), 'x', s.propcircle_x, s.propcircle_y, 'b', s.proplijn_x,  s.proplijn_y, 'g', s.propkop_x, s.propkop_y, 'r');
    hold on;
    axis([0, 20, 0 20])
    
end

