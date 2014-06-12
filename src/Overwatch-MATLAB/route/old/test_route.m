clc; clear all;


%-------------------------------------------------------------------------------------------
%Test: Als de auto naar boven rijdt en een bocht met de klok mee maakt
%-------------------------------------------------------------------------------------------
Oldlocation = [3 1]; Currentlocation = [3 5]; 
s = Route;


%Ik heb een circle (x-4)^2+(y-5)^2 = 10
cx = 4; cy = 5; r = sqrt(10); x_begin = 3;
a_maximum = acos((x_begin-cx)/r);
delta_a = 2*a_maximum/100;

for j = 0:100
    a = a_maximum - j*delta_a;
    x = cx + r*cos(a);
    y = cy + r*sin(a);
    waypoints = [x, y];
    
    [distance, Ref_angle] = DetermineRoute(s, Oldlocation, Currentlocation, waypoints);
    if j == 0 
        constant = distance;
        distance_vector = [distance];
        ref_angle_vector = [Ref_angle];
    else
        distance_vector = [distance_vector distance];
        ref_angle_vector = [ref_angle_vector Ref_angle];
    end
end

slope1 = (distance - constant)/(100*delta_a)


figure(1)

subplot(2, 1, 1);
plot(distance_vector);

subplot(2, 1, 2);
plot(ref_angle_vector*180/pi);




clear all;
%-------------------------------------------------------------------------------------------
%Test: Als de auto naar links rijdt en een bocht met de klok mee maakt
%-------------------------------------------------------------------------------------------
Oldlocation = [20 20]; Currentlocation = [15 20]; 
s = Route;


%Ik heb een circle (x-4)^2+(y-5)^2 = 10
cx = 15; cy = 21; r = sqrt(50); x_begin = 8; y_begin = 20;
berekend_hoek = pi - acos((x_begin-cx)/r);
a_maximum = pi + berekend_hoek;
totale_afwijking = pi + 2*berekend_hoek;
delta_a = totale_afwijking/100;

for j = 0:100
    a = a_maximum - j*delta_a;
    x = cx + r*cos(a);
    y = cy + r*sin(a);
    waypoints = [x, y];
    
    [distance, Ref_angle] = DetermineRoute(s, Oldlocation, Currentlocation, waypoints);
    if j == 0 
        constant = distance;
        distance_vector = [distance];
        ref_angle_vector = [Ref_angle];
    else
        distance_vector = [distance_vector distance];
        ref_angle_vector = [ref_angle_vector Ref_angle];
    end
end

slope2 = (distance - constant)/(100*delta_a)

figure(2)

subplot(2, 1, 1);
plot(distance_vector);

subplot(2, 1, 2);
plot(ref_angle_vector*180/pi);







