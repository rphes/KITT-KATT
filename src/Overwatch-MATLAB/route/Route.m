%<<<<<<< HEAD
%% This is a class calling all other functions in the right order


classdef Route
    properties (SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = Route()
        end
        
        % Determine route
        function [CurrentDistance, ReferenceAngle] = DetermineRoute(Self, Oldlocation, Currentlocation, Waypoints)

            
            
            
            
            

%   Punt [x_loc,y_loc] is de locatie op de huidige tijdstip
%   Punt [x0_loc,y0_loc] is de locatie op de vorige tijdstip
%   Punt [waypoint_x,waypoint_y] is het eindpunt
x0_loc = Oldlocation(1);
y0_loc = Oldlocation(2);    
x_loc = Currentlocation(1);
y_loc = Currentlocation(2);
waypoint_x = Waypoints(1);
waypoint_y = Waypoints(2);

turning_radius = 1;  %De draaicirkel in meter.    








%In dit blok bereken ik de rechte stuk lijn(l_recht).
%----------------------------------------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------------------------------------

%Bereken de kortste afstand van eindpunt naar de lijn waar de auto op rijdt(punt_lijn), oftwel richtingslijn.
    if x_loc == x0_loc  %Lijn is:  x -slope*y - b = 0. Waarbij slope = 0
        punt_lijn = abs(waypoint_x - x_loc);
        if y_loc > y0_loc
            vector_beweeg_richting = [0, 1];
        else
            vector_beweeg_richting = [0, -1];
        end
            
      
    else                %Lijn is:  -slope*x + y - b = 0
        slope = (y_loc - y0_loc)/(x_loc - x0_loc);
        b = y_loc - slope*x_loc;
        punt_lijn = abs(-slope*waypoint_x + waypoint_y - b)/sqrt(slope^2 + 1);
        if x_loc > x0_loc
            vector_beweeg_richting = [1, slope];
        else
            vector_beweeg_richting = [-1, -slope];
        end
    end
    
    
%Bereken de afstand tussen de huidige locatie en de waypoint(punt_punt).
    punt_punt = sqrt((x_loc - waypoint_x)^2 + (y_loc - waypoint_y)^2);

    
%Bereken de rechte stuk van het traject(l_recht).
l_recht = ((punt_lijn - turning_radius)^2 - punt_lijn^2 + punt_punt^2 - turning_radius^2)^(1/2);

%----------------------------------------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------------------------------------





















%In dit blok bereken ik de afgelegde stuk op de kromme(l_kromme).
%----------------------------------------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------------------------------------


%Ik maak een nieuwe lijn die door de huidige locatie en de waypoint gaat.
%Vervolgens bereken ik de hoek tussen beide lijnen met behulp van vectoren.
    if x_loc == waypoint_x  %Lijn is:  x -slope*y - b = 0
        if waypoint_y > y_loc
            vector_waypoint = [0, 1];
        else
            vector_waypoint = [0, -1];
        end
        
    else                    %Lijn is:  -slope*x + y - b = 0
        slope_w = (waypoint_y - y_loc)/(waypoint_x - x_loc);
        if waypoint_x > x_loc
            vector_waypoint = [1, slope_w];
        else
            vector_waypoint = [-1, -slope_w];
        end
        
    end
    costheta = dot(vector_beweeg_richting,vector_waypoint)/(norm(vector_beweeg_richting)*norm(vector_waypoint));
    hoek_theta = acos(costheta);
    theta = hoek_theta*180/pi
    
    
    
    
    
%Bereken de RD_hoek
    
    if x_loc == x0_loc
        c = y_loc;  % y = perp_lope*x + c
        
        %Snijpunt van deze lijn met een cirkel met straat R om de huidige
        %locatie.
        A = 1;
        B = 2*(-x_loc);
        C = (y_loc^2 - turning_radius^2 + x_loc^2 - 2*c*y_loc + c^2);
        x1 = ( -B + sqrt(B^2-4*A*C) )/(2*A);
        x2 = ( -B - sqrt(B^2-4*A*C) )/(2*A);
        y1 = c;
        y2 = c;
        
        %Kies 1 van deze snijpunten
        if waypoint_x > x_loc
            if x1 > x2
                r_point = [x1, y1];
            else 
                r_point = [x2, y2];
            end
        else
            if x1 < x2
                r_point = [x1, y1];
            else
                r_point = [x2, y2];
            end
        end
        
        
        
    elseif slope ~= 0
        perp_slope = -1/slope;
        c = y_loc  - perp_slope*x_loc;  % y = perp_lope*x + c
        
        %Snijpunt van deze lijn met een cirkel met straat R om de huidige
        %locatie.
        A = perp_slope^2 + 1;
        B = 2*(perp_slope*c - perp_slope*y_loc - x_loc);
        C = (y_loc^2 - turning_radius^2 + x_loc^2 - 2*c*y_loc + c^2);
        x1 = ( -B + sqrt(B^2-4*A*C) )/(2*A);
        x2 = ( -B - sqrt(B^2-4*A*C) )/(2*A);
        y1 = perp_slope*x1 + c;
        y2 = perp_slope*x2 + c;
       
        %Kies 1 van deze snijpunten
        y_lijn = slope*waypoint_x + b;
        if waypoint_y > y_lijn
            if y1 > y2
                r_point = [x1, y1];
            else 
                r_point = [x2, y2];
            end
        else
            if y1 < y2
                r_point = [x1, y1];
            else
                r_point = [x2, y2];
            end
        end
        
        
        
    else
        x1 = x_loc;
        x2 = x_loc;
        y1 = y_loc + turning_radius;
        y2 = y_loc - turning_radius;
        if waypoint_y > y_loc
            if y1 > y2
                r_point = [x1, y1];
            else 
                r_point = [x2, y2];
            end
        else
            if y1 < y2
                r_point = [x1, y1];
            else
                r_point = [x2, y2];
            end
        end
    
        
    end
    
    
    
    %Bereken de hoek tussen de loodrechte lijn en de D_lijn
    if r_point(1) == waypoint_x  
        if waypoint_y > r_point(2)
            vector_RD = [0, 1];
        else
            vector_RD = [0, -1];
        end
        
    else                    
        slope_RD = (waypoint_y - r_point(2))/(waypoint_x - r_point(1));
        if waypoint_x > r_point(1)
            vector_RD = [1, slope_RD];
        else
            vector_RD = [-1, -slope_RD];
        end
    end
    
   
    if r_point(1) == x_loc  
        if y_loc > r_point(2)
            vector_RP = [0, 1];
        else
            vector_RP = [0, -1];
        end
        
    else                    
        slope_RP = (y_loc - r_point(2))/(x_loc - r_point(1));
        if x_loc > r_point(1)
            vector_RP = [1, slope_RP];
        else
            vector_RP = [-1, -slope_RP];
        end
    end
    
    cosgamma = dot(vector_RD,vector_RP)/(norm(vector_RD)*norm(vector_RP));
    hoek_gamma = acos(cosgamma);
    gamma = hoek_gamma*180/pi
 
    r_punticos = r_point;


    %Bereken nu hoek van de kromme aan de hand van hoek_theta en hoek_gamma
    if hoek_theta > pi/2
        if hoek_gamma > pi/2
            alpha = pi - acos(turning_radius/(punt_punt^2 - punt_lijn^2 + (punt_lijn - turning_radius)^2)^(1/2)) + atan((punt_punt^2 - punt_lijn^2)^(1/2)/(punt_lijn - turning_radius));
        else
            alpha = 2*pi - acos(turning_radius/(punt_punt^2 - punt_lijn^2 + (punt_lijn - turning_radius)^2)^(1/2)) - atan((punt_punt^2 - punt_lijn^2)^(1/2)/(turning_radius - punt_lijn));
        end
    else
        if hoek_gamma > pi/2
            alpha = pi - acos(turning_radius/(punt_punt^2 - punt_lijn^2 + (punt_lijn - turning_radius)^2)^(1/2)) - atan((punt_punt^2 - punt_lijn^2)^(1/2)/(punt_lijn - turning_radius)); 
        else
            alpha = pi/2 - acos(turning_radius/(punt_punt^2 - punt_lijn^2 + (punt_lijn - turning_radius)^2)^(1/2)) + atan((punt_lijn - turning_radius)/(punt_punt^2 - punt_lijn^2)^(1/2));
        end
    end 
    
%Bereken afgelegde weg tijdens de draaiïng(l_krom).
hoek_alpha = alpha*180/pi
l_kromme = alpha*turning_radius;
%----------------------------------------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------------------------------------
    















CurrentDistance = l_recht + l_kromme;


%Bereken ref_hoek
%Dit gebeurd aan de hand van vectoren waarbij de y-as de vector [0, 1] is.
y = [0, 1];

    if waypoint_x == 0  %Lijn is:  x -slope*y - b = 0
        waypoint_v = [0, 1];
        
    else                %Lijn is:  -slope*x + y - b = 0
        slope_w = waypoint_y/waypoint_x;
            waypoint_v = [1, slope_w];
    end


cosbetha = dot(y,waypoint_v)/(norm(y)*norm(waypoint_v));
ReferenceAngle = -acos(cosbetha);







             end
      end
end


%>>>>>>> d343c4010c97cbd9b584f1336bcb1893aed22beb
