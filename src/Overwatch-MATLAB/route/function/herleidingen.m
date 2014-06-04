clc; clear all;


syms x_loc y_loc turning_radius perp_slope c A B C x1 x2 y1 y2

A = perp_slope^2 + 1;
B = 2*(perp_slope*c - perp_slope*y_loc - x_loc);
C = (y_loc^2 - turning_radius^2 + x_loc^2 - 2*c*y_loc + c^2);
x1 = ( -B + sqrt(B^2-4*A*C) )/(2*A);
x1 = ( -B - sqrt(B^2-4*A*C) )/(2*A);
y1 = perp_slope*x1 + c;
y2 = perp_slope*x2 + c;


clc; clear all;
syms C G D B R P_P P_L N omega omega2 alpha alpha2 theta theta2 PI

%Dit is voor -90<D<90 graden
C = P_L - R;
G = sqrt(P_P^2 - P_L^2);
D = sqrt(G^2 + C^2);
B = sqrt(D^2 - R^2);

afstand_rechte_stuk =  B;

%Hoek tussen de vectoren > 90 graden
theta = atan(G/C);
N = acos(R/D);
omega = N -theta;
alpha = PI - omega;

%Hoek tussen de vectoren < 90 graden
theta2 = atan(G/C);
omega2 = acos(R/D);
alpha2 = PI - theta2 - omega2;



%-------------------------------------------------------------------------
clear all;
syms C G D B R P_P P_L N omega omega2 alpha alpha2 theta theta2 PI
%Dit is voor 90<D<180 graden
C = R - P_L;
G = sqrt(P_P^2 - P_L^2);
D = sqrt(C^2 + G^2);
B = sqrt(D^2 - R^2);

afstand = B;

%Boven de loodrechte lijn
theta = atan(C/G);
omega = acos(R/D);
alpha = PI/2 - theta - omega

%Onder de loodrechte lijn
theta2 = atan(G/C);
omega2 = acos(R/D);
alpha2 = 2*PI - theta - omega


