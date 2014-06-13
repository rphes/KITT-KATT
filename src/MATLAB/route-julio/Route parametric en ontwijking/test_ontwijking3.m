clc; clear; clear all;
hold off;
close all;
forrie = 0;
N = 200;
keer = 1;
Volgende_positie = 0;
testalpha = 1;
test2 = 1;

while N > 1
    if forrie == 0
        Currentlocation = [16 6];
        Currentangle = 0; 
        s = Route;
        Waypoints = [1 12];
        Sensor = [10, 10];
        Steering = 150;
        stopmetcircle = 0;
    else
        Sensor = [10, 10];
        test = 1;
        if alpha > 1e-1 && stopmetcircle == 0
            test = 1
            Currentlocation = [s.propcircle_x(forrie) s.propcircle_y(forrie)];
            positie = Currentlocation;
            volgende_positie = [s.propcircle_x(forrie + 1) s.propcircle_y(forrie + 1)];
            
            beweeg = [cos(Currentangle) sin(Currentangle)];
            hoek_current = atan2(Currentlocation(2) - s.propr_point(2), Currentlocation(1) - s.propr_point(1));
            
            v1 = beweeg;
            v2 = s.propr_point - Currentlocation;
            ang = atan2(v1(1)*v2(2)-v2(1)*v1(2),v1(1)*v2(1)+v1(2)*v2(2));  
            Angle = mod(-180/pi * ang, 360);
            
            if  Angle < 180
                v2 = positie - volgende_positie;
            else 
                v2 = volgende_positie - positie;
            end
            
            
            
            v1 = [1 0];

            %Bereken de hoek v2 tegenover v1 met de klok mee.
            ang = atan2(v1(1)*v2(2)-v2(1)*v1(2),v1(1)*v2(1)+v1(2)*v2(2));  
            Angle = mod(-180/pi * ang, 360);
            Currentangle = 2*pi - Angle*pi/180;
            de_hoekies = Currentangle*pi/180;
            tijdelijke_forrie = forrie;
            
            if testalpha == 0
                test2 = 0; 
            end
            
        else
            test = 0
            stopmetcircle = 1;
            verschil_in_forrie = forrie - tijdelijke_forrie;
            Currentlocation = [s.proplijn_x(1) s.proplijn_y(1)];
            
            Endlocation = s.propeindpunt; 
            
            v2 = Endlocation - Currentlocation;
            v1 = [1 0];

            %Bereken de hoek v2 tegenover v1 met de klok mee.
            ang = atan2(v1(1)*v2(2)-v2(1)*v1(2),v1(1)*v2(1)+v1(2)*v2(2));  
            Angle = mod(-180/pi * ang, 360);
            Currentangle = 2*pi - Angle*pi/180;
            
            check_eind = Waypoints - Currentlocation;
            check_circle = s.propTemp_waypoint - Currentlocation;
            check2 = norm(check_circle);
            
            if norm(check_eind) < 0.5
                N = 0;
                break;
            end
            
            if check2 < 0.1
                stopmetcircle = 0;
                forrie = 0;
                testalpha = 0;
            end
            
            
            if verschil_in_forrie == 5 && keer == 1;
                
                Sensor = [0, 0]
                keer = 0;
                stopmetcircle = 0;
                forrie = 0;
                
            end
            
            

        end
        
        
    end
    
   
    
    [distance, Ref_angle] = DetermineRoute(s, Currentlocation, Currentangle, Waypoints, Sensor, Steering);
    Object = s.propObjectlocation;
    if test2 == 0
        plot(s.propcircle_x, s.propcircle_y, '+');
        break;
    end
    

 
    if Sensor == [0 0]
        plot(Currentlocation(1), Currentlocation(2), 'o', Object(1), Object(2), 's', s.propr_point(1), s.propr_point(2), '+', s.propTemp_waypoint(1), s.propTemp_waypoint(2), 'b*', s.propkop_x, s.propkop_y, 'r');
        Volgende_positie = 1;
    else
        plot(Currentlocation(1), Currentlocation(2), 'o', s.propTemp_waypoint(1), s.propTemp_waypoint(2), 'b*', s.propkop_x, s.propkop_y, 'r');
    end
    
    hold on;
    axis([0, 20, 0 20])
    alpha = s.propalpha;
    
    
    forrie = forrie + 1;
end
            
            
            

