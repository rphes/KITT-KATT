
%% This is a class calling all other functions in the right order


classdef Route<handle
    properties (SetAccess = private)
        propr_point
        propcircle_x
        propcircle_y
        proplijn_x
        proplijn_y
        propkop_x
        propkop_y
    end
    
    methods
        % Constructor
        function Self = Route()
            Self.propr_point = [0 0];
            Self.propcircle_x = [zeros(1,101)];
            Self.propcircle_y = [zeros(1,101)];
            Self.proplijn_x = [0 0];
            Self.proplijn_y = [0 0];
            Self.propkop_x = [0 0];
            Self.propkop_y = [0 0];
        end
        
        % Determine route
        function [CurrentDistance, ReferenceAngle] = DetermineRoute(Self, Currentlocation, Currentangle, Waypoints)
                


                turning_radius = 1.345;  %De draaicirkel in meter.

                beweeg = [cos(Currentangle), sin(Currentangle)];


                
                
                %Bereken r_point met parameterisering
                perp_beweeg1 = [sin(Currentangle), -cos(Currentangle)]; 
                perp_beweeg2 = [-sin(Currentangle), cos(Currentangle)];
                
                r_point1 = Currentlocation + turning_radius*perp_beweeg1;
                r_point2 = Currentlocation + turning_radius*perp_beweeg2;
                
                Afstand_way1 = norm(Waypoints - r_point1);
                Afstand_way2 = norm(Waypoints - r_point2);
                
                if Afstand_way1 < Afstand_way2
                    r_point = r_point1;
                else
                    r_point = r_point2;
                end

                
                
                
                
                %Bereken de kromme
                r_waypoints = Waypoints - r_point;
                r_location  = Currentlocation - r_point;
                loc_wp = Waypoints - Currentlocation;
              
                coshoek_betha = dot(loc_wp,beweeg)/(norm(loc_wp)*norm(beweeg));
                hoek_betha = acos(coshoek_betha);
               
                coshoek_n = dot(r_location,r_waypoints)/(norm(r_location)*norm(r_waypoints));
                hoek_n = acos(coshoek_n);
                
                lengte_D = norm(r_waypoints);
                hoek_omega = acos(turning_radius/lengte_D);
               
                if hoek_betha < pi/2
                    alpha = hoek_n - hoek_omega;
                else
                    alpha = 2*pi - hoek_n - hoek_omega;
                end;
                l_kromme = alpha*turning_radius;
                
                %Bereken de rechte lijn 
                l_recht = sqrt(lengte_D^2 - turning_radius^2);
                
                %Totale afstand
                CurrentDistance = l_recht + l_kromme;
                
                
                
                %Bereken ref_hoek
                %Dit gebeurd aan de hand van vectoren waarbij de y-as de vector [0, 1] is.
                x = [1, 0];
                cosbetha = dot(x,Waypoints)/(norm(x)*norm(Waypoints));
                ReferenceAngle = acos(cosbetha);
                
                
                
                
                
                
%-------------------------------------------------------------------------------------------------------------------------------------------                
%-------------------------------------------------------------------------------------------------------------------------------------------                
%EINDE CODE. H
%HIERNA KOMT EXTRA OM TE PLOTTEN
%-------------------------------------------------------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------------------------------------------                
                
                
                
                
                
                
                
                
                
                
                %-------------------------------------
                %Dit is om de kromme te plotten
                %-------------------------------------
                
                delta_alpha = alpha/100;
                
                %Hoek van Currentlocation op staat:
                hoek_current = atan2(Currentlocation(2) - r_point(2), Currentlocation(1) - r_point(1));
                
                v1 = beweeg
                v2 = Waypoints - r_point
                
                ang = atan2(v1(1)*v2(2)-v2(1)*v1(2),v1(1)*v2(1)+v1(2)*v2(2));
                Angle = mod(-180/pi * ang, 360)
                
                
                if  Angle < 180
                    begin_teken  = hoek_current - alpha;
                else 
                    begin_teken =  hoek_current;
                end
                
                
                
                for j = 0:100
                    huidig_alpha = begin_teken + j*delta_alpha;
                    x_circle = r_point(1) + turning_radius*cos(huidig_alpha);
                    y_circle = r_point(2) + turning_radius*sin(huidig_alpha);
                    if j == 0 
                        circle_x = [x_circle];
                        circle_y = [y_circle];
                        beginpunt_lijn = [x_circle y_circle];
                    else
                        circle_x = [circle_x x_circle];
                        circle_y = [circle_y y_circle];
                        beginpunt_lijn2 = [x_circle y_circle];
                    end
                end
                %-------------------------------------
                %-------------------------------------
                
                if  Angle > 180
                    beginpunt_lijn = beginpunt_lijn2;
                end
                
                
                %-------------------------------------
                %Dit is om de rechte lijn te tekenen
                %-------------------------------------
                beginlijn_waypoints = Waypoints - beginpunt_lijn;
                unit_bw = beginlijn_waypoints/norm(beginlijn_waypoints);
                eindpunt_lijn = beginpunt_lijn + l_recht*unit_bw;
                
                lijn_x = [beginpunt_lijn(1) eindpunt_lijn(1)];
                lijn_y = [beginpunt_lijn(2) eindpunt_lijn(2)];
                
                %-------------------------------------
                %-------------------------------------
                
                
                
                %-------------------------------------
                %Dit is om de kop van de auto te tekenen
                %-------------------------------------
                
                koppunt = Currentlocation + 0.5*beweeg;
                kop_x = [Currentlocation(1) koppunt(1)];
                kop_y = [Currentlocation(2) koppunt(2)];
                
                %-------------------------------------
                %-------------------------------------
                
                
                Self.propr_point = r_point;
                Self.propcircle_x = circle_x;
                Self.propcircle_y = circle_y;
                Self.proplijn_x = lijn_x;
                Self.proplijn_y = lijn_y;
                Self.propkop_x = kop_x;
                Self.propkop_y = kop_y;
                
           
                

        end
    end
end
