clc; clear all;



Currentlocation = [5 5]; Currentangle = pi/4; s = Route;



%Ik heb een circle (x-p)^2+(y-q)^2 = r^2
cx = Currentlocation(1); cy = Currentlocation(2); r = sqrt(5); x_begin = 3;
a_maximum = 2*pi;
delta_a = 2*pi/4;

for j = 1:4
    r = r*1.2;
    a = a_maximum - j*delta_a;
    x = cx + r*cos(a);
    y = cy + r*sin(a);
    Waypoints = [x, y];
    
    [distance, Ref_angle] = DetermineRoute(s, Currentlocation, Currentangle, Waypoints);
    
    figure(1)
    subplot(2, 2, j)
    plot(Currentlocation(1), Currentlocation(2), 'o', s.propr_point(1), s.propr_point(2), '+', Waypoints(1), Waypoints(2), 'x', s.propcircle_x, s.propcircle_y, 'b', s.proplijn_x,  s.proplijn_y, 'g', s.propkop_x, s.propkop_y, 'r');
    axis([0, 10, 0 10])
end













clc; clear all;

Currentlocation = [5 5]; Currentangle = 3*pi/4; s = Route;



%Ik heb een circle (x-p)^2+(y-q)^2 = r^2
cx = Currentlocation(1); cy = Currentlocation(2); r = sqrt(5); x_begin = 3;
a_maximum = 2*pi;
delta_a = 2*pi/4;

for j = 1:4
    r = r*1.2;
    a = a_maximum - j*delta_a;
    x = cx + r*cos(a);
    y = cy + r*sin(a);
    Waypoints = [x, y];
    
    [distance, Ref_angle] = DetermineRoute(s, Currentlocation, Currentangle, Waypoints);
    
    figure(2)
    subplot(2, 2, j)
    plot(Currentlocation(1), Currentlocation(2), 'o', s.propr_point(1), s.propr_point(2), '+', Waypoints(1), Waypoints(2), 'x', s.propcircle_x, s.propcircle_y, 'b', s.proplijn_x,  s.proplijn_y, 'g', s.propkop_x, s.propkop_y, 'r');
    axis([0, 10, 0 10])
end




















clc; clear all;

Currentlocation = [5 5]; Currentangle = 5*pi/4; s = Route;



%Ik heb een circle (x-p)^2+(y-q)^2 = r^2
cx = Currentlocation(1); cy = Currentlocation(2); r = sqrt(5); x_begin = 3;
a_maximum = 2*pi;
delta_a = 2*pi/4;

for j = 1:4
    r = r*1.2;
    a = a_maximum - j*delta_a;
    x = cx + r*cos(a);
    y = cy + r*sin(a);
    Waypoints = [x, y];
    
    [distance, Ref_angle] = DetermineRoute(s, Currentlocation, Currentangle, Waypoints);
    
    figure(3)
    subplot(2, 2, j)
    plot(Currentlocation(1), Currentlocation(2), 'o', s.propr_point(1), s.propr_point(2), '+', Waypoints(1), Waypoints(2), 'x', s.propcircle_x, s.propcircle_y, 'b', s.proplijn_x,  s.proplijn_y, 'g', s.propkop_x, s.propkop_y, 'r');
    axis([0, 10, 0 10])
end



















clc; clear all;

Currentlocation = [5 5]; Currentangle = 7*pi/4; s = Route;



%Ik heb een circle (x-p)^2+(y-q)^2 = r^2
cx = Currentlocation(1); cy = Currentlocation(2); r = sqrt(5); x_begin = 3;
a_maximum = 2*pi;
delta_a = 2*pi/4;

for j = 1:4
    r = r*1.2;
    a = a_maximum - j*delta_a;
    x = cx + r*cos(a);
    y = cy + r*sin(a);
    Waypoints = [x, y];
    
    [distance, Ref_angle] = DetermineRoute(s, Currentlocation, Currentangle, Waypoints);
    
    figure(4)
    subplot(2, 2, j)
    plot(Currentlocation(1), Currentlocation(2), 'o', s.propr_point(1), s.propr_point(2), '+', Waypoints(1), Waypoints(2), 'x', s.propcircle_x, s.propcircle_y, 'b', s.proplijn_x,  s.proplijn_y, 'g', s.propkop_x, s.propkop_y, 'r');
    axis([0, 10, 0 10])
end
