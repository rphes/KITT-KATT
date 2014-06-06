
%% This is a class calling all other functions in the right order


classdef Route
    properties (SetAccess = private)
        Oldlocation
        Initial_point
    end
    
    methods
        % Constructor
        function Self = Route()
            Self.Oldlocation = [0, 0];
            Initial_point = 0;
        end
        
        % Determine route
        function [CurrentDistance, ReferenceAngle] = DetermineRoute(Self, Currentlocation, Currentangle, Waypoints)
                
                
                %   Punt [x_loc,y_loc] is de locatie op de huidige tijdstip
                %   Punt [x0_loc,y0_loc] is de locatie op de vorige tijdstip
                %   Punt [waypoint_x,waypoint_y] is het eindpunt    
                x_loc = Currentlocation(1);
                y_loc = Currentlocation(2);
                waypoint_x = Waypoints(1);
                waypoint_y = Waypoints(2);

                turning_radius = 0.65;  %De draaicirkel in meter.
            
               
               
                
                beweeg = [cos(Currentangle), sin(Currentangle)];
                perp_beweeg = [sin(Currentangle), -cos(Currentangle)];
                
                
                
              



                %Bereken het midden van de turning cicle
                if  beweeg(1) ~= 0
                    slope = beweeg(2)/beweeg(1);
                    b = y_loc - slope*x_loc;
                end
                
                
                if beweeg(1) = 0
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
                
                
                
                
                
                %Bereken de kromme
                r_waypoints = Waypoints - r_point;
                r_location  = Currentlocation - r_point;
                loc_wp = Waypoints - Currentlocation;
                
                lengte_D = norm(r_waypoints);
               
                coshoek_betha = dot(loc_wp,beweeg)/(norm(loc_wp)*norm(beweeg));
                hoek_betha = acos(coshoek_betha);
               
                coshoek_n = dot(r_location,r_waypoints)/(norm(r_location)*norm(r_waypoints));
                hoek_n = acos(coshoek_n);
               
                hoek_omega = acos(turning_radius/lengte_D);
               
                
                
                
                if hoek_betha < pi/2
                    alpha = hoek_n - hoek_omega;
                else
                    alpha = 2*pi - hoek_n - hoek_omega;
                end;
                
                
                l_recht = sqrt(lengte_D - turning_radius);
                l_kromme = alpha*turning_radius;
                
                CurrentDistance = l_recht + l_kromme;
                


                

    
        end
    end
end
