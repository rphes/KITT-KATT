
%% This is a class calling all other functions in the right order


classdef Route<handle
    properties (SetAccess = private)
        %dit zijn properties om functie geenobject te testen
        propr_point
        propcircle_x
        propcircle_y
        proplijn_x
        proplijn_y
        propkop_x
        propkop_y
        
        %Dit zijn properties om functie lr_object te testen
        propCirclepoint
        propr_point2
        
        
        %Dit zijn properties die daadwerkelijk gebruikt worden
        propTemp_waypoint
        
    end
    
    methods
        % Constructor
        function Self = Route()
            Self.propr_point = [0 0];
            Self.propcircle_x = [];
            Self.propcircle_y = [];
            Self.proplijn_x = [0 0];
            Self.proplijn_y = [0 0];
            Self.propkop_x = [0 0];
            Self.propkop_y = [0 0];
            
            Self.propTemp_waypoint = [0 0];
        end
        
        
        
        
        % Determine route
        function [CurrentDistance, ReferenceAngle] = DetermineRoute(Self, Currentlocation, Currentangle, Waypoints, Sensors)
            
                [turning_radius, beweeg, r_point1, r_point2, Uiterste_punt, Sens_thres, length_objects] = standaardvar(Currentlocation, Currentangle);
                
                if Sensors(1) < Sens_thres && Sensors(2) < Sens_thres
                    [CurrentDistance, ReferenceAngle] = lr_object(Self, Currentlocation, Currentangle);
                elseif Sensors(1) < 0.9
                    draai = 'links';
                elseif Sensors(2) < 0.9
                    draai = 'rechts';
                else
                    
                        
                [CurrentDistance, ReferenceAngle, r_point, alpha, l_recht] = geen_object(Self, Currentlocation, Currentangle, Waypoints);
                
                
                %Dit is om de berekende lengtes te testen
                test_lengths(Self, alpha, Currentlocation, r_point, beweeg, turning_radius, Waypoints, l_recht);
                

                end
        end
        
        
        
        %Bereken Distance en Angle als er geen object is
        function [CurrentDistance, ReferenceAngle, r_point, alpha, l_recht] = geen_object(Self, Currentlocation, Currentangle, Waypoints)
                    
                    [turning_radius, beweeg, r_point1, r_point2, Uiterste_punt, Sens_thres, length_objects] = standaardvar(Currentlocation, Currentangle);
                
                    %Bepaal het middel van mijn turning circle
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
                    l_kromme = abs(alpha)*turning_radius;

                    %Bereken de rechte lijn 
                    l_recht = sqrt(lengte_D^2 - turning_radius^2);

                    %Totale afstand
                    CurrentDistance = l_recht + l_kromme;



                    %Bereken ref_hoek
                    %Dit gebeurd aan de hand van vectoren waarbij de y-as de vector [0, 1] is.
                    x = [1, 0];
                    cosbetha = dot(x,Waypoints)/(norm(x)*norm(Waypoints));
                    ReferenceAngle = acos(cosbetha);
        end
        
        
        
        %Bereken de tijdelijke Distance en Angle als beide sensoren een
        %object zien.
        function [CurrentDistance, ReferenceAngle] = lr_object(Self, Currentlocation, Currentangle)
                  
                    [turning_radius, beweeg, r_point1, r_point2, Uiterste_punt, Sens_thres, length_objects] = standaardvar(Currentlocation, Currentangle); 
                    
                    draai = 'dunno';
                    
                    %Bereken de kromme afstand
                    alpha = 80*pi/180;
                    l_kromme = turning_radius*alpha;
                   
                    %De rechte kan nog getuned worden
                    l_recht = sqrt((length_objects+turning_radius)^2 + Sens_thres^2);
                    
                    CurrentDistance = l_recht + l_kromme;
                    
                    
                    %Bepaal bepaal welke bocht de auto maakt(links of rechts)
                    [r_point, draai] = origin(Currentlocation, Currentangle, Uiterste_punt, r_point1, r_point2, draai);
                    Self.propr_point2 = r_point;
                    
                    
                    %Bepaal de positie van mijn tijdelijke doel
                    [Temp_waypoint, Circlepoint] = tempwaypoint(Currentlocation, r_point, alpha, draai, Currentangle, l_recht);
                    
                    
                    Self.propTemp_waypoint = Temp_waypoint;
                    Self.propCirclepoint = Circlepoint;
                    
                    
                    x = [1, 0];
                    cosbetha = dot(x,Temp_waypoint)/(norm(x)*norm(Temp_waypoint));
                    ReferenceAngle = acos(cosbetha);
            
        end
        
        
        
        %Dit is om functie geen object te testen   
        function test_lengths(Self, alpha, Currentlocation, r_point, beweeg, turning_radius, Waypoints, l_recht)
                %Deze functie is om de lengtes te testen
                
                delta_alpha = abs(alpha)/100;
                
                %Hoek van Currentlocation op staat:
                hoek_current = atan2(Currentlocation(2) - r_point(2), Currentlocation(1) - r_point(1));
                
                
                Angle = twee_pi(beweeg, r_point - Currentlocation);
                
                
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

























        %Functie bepaald wat het middenpunt in van de draaicirkel    
        function [r_point, draai] = origin(Currentlocation, Currentangle, Uiterste_punt, r_point1, r_point2, draai)
            %Functie bepaald wat het middenpunt in van de draaicirkel
            
            beweeg = [cos(Currentangle), sin(Currentangle)];
            snijpunt = [];

            %Dit is de lijn loodrecht door de beweegrichting
            richting_pb = [sin(Currentangle) -cos(Currentangle)];
            constant_pb = [Currentlocation(1) Currentlocation(2)];

            %Dit is de lijn voor de linkergrens
            richting_lg = [0 1];
            constant_lg = [0 0];

            %Dit is de lijn voor de ondergrens
            richting_og = [1 0];
            constant_og = [0 0];

            %Dit is de lijn voor de rechtergrens
            richting_rg = [0 1];
            constant_rg = [Uiterste_punt(1) 0];

            %Dit is de lijn voor de bovengrens 
            richting_bg  = [1 0];
            constant_bg  = [0 Uiterste_punt(2)];


            snijpunt_links = Intersection(richting_pb, constant_pb, richting_lg, constant_lg);
            if snijpunt_links(2) >= 0 && snijpunt_links(2) <= Uiterste_punt(2)
                        snijpunt = [snijpunt snijpunt_links];
            end 

            snijpunt_onder = Intersection(richting_pb, constant_pb, richting_og, constant_og);
            if snijpunt_onder(1) >= 0 && snijpunt_onder(1) <= Uiterste_punt(1)
                        snijpunt = [snijpunt snijpunt_onder];
            end

            snijpunt_rechts = Intersection(richting_pb, constant_pb, richting_rg, constant_rg);
            if snijpunt_rechts(2) >= 0 && snijpunt_rechts(2) <= Uiterste_punt(2)
                    snijpunt = [snijpunt snijpunt_rechts];
            end

            snijpunt_boven = Intersection(richting_pb, constant_pb, richting_bg, constant_bg);
            if snijpunt_boven(1) >= 0 && snijpunt_boven(1) <= Uiterste_punt(1)
                        snijpunt = [snijpunt snijpunt_boven];
            end


            snijvector1 = [snijpunt(1) snijpunt(2)] - Currentlocation;
            snijvector2 = [snijpunt(3) snijpunt(4)] - Currentlocation;
            
            
            if strcmp(draai,'dunno') == 1
                [r_point, draai] = cirkel_draai(snijvector1, snijvector2, r_point1, r_point2, beweeg);
            elseif strcmp(draai,'links') == 1
            elseif strcmp(draai,'rechts') == 1
            end
            
        end
        
        %Functie berekend de snijpunt tussen twee lijnen
        function [snijpunt] = Intersection(richting1, constant1, richting2, constant2)
            %Functie berekend de snijpunt tussen twee lijnen
            matrix = [richting1; -richting2];
            determinant = det(matrix);
            if abs(determinant) > 1e-10 

                FACTORS = (constant2 - constant1)*inv(matrix);
                factor = FACTORS(1);
                snijpunt = constant1 + factor*richting1;
            else
                snijpunt = [100 100];
            end
        end
        
        %Functie berekend welke kant die op moet draaien en de middel van de draaicirkel.
        function [r_point, draai] = cirkel_draai(snijvector1, snijvector2, r_point1, r_point2, beweeg)
            %Functie berekend welke kant die op moet draaien en de middel van de draaicirkel.
            
            
            
            afstand1 = norm(snijvector1);
            afstand2 = norm(snijvector2);
            if afstand1 > afstand2
                Angle = twee_pi(beweeg, snijvector1);
                if Angle < 180
                    r_point = r_point1;
                    draai = 'rechts';
                else
                    r_point = r_point2;
                    draai = 'links';
                end
            else
                Angle = twee_pi(beweeg, snijvector2);
                if Angle < 180
                    r_point = r_point1;
                    draai = 'rechts';
                else
                    r_point = r_point2;
                    draai = 'links';
                end
            end
        end
        
        %Dit zijn de variabelen die vaak in andere function worden gebruikt
        function [turning_radius, beweeg, r_point1, r_point2, Uiterste_punt, Sens_thres, length_objects] = standaardvar(Currentlocation, Currentangle)
            %Dit zijn de variabelen die vaak in andere function worden
            %gebruikt
            turning_radius = 0.7;
            Uiterste_punt = [20 20];
            Sens_thres = 0.9;
            length_objects = 2;
            
            beweeg = [cos(Currentangle), sin(Currentangle)];
            
            
            %Bereken r_point met parameterisering
            perp_beweeg1 = [sin(Currentangle), -cos(Currentangle)]; 
            perp_beweeg2 = [-sin(Currentangle), cos(Currentangle)];

            r_point1 = Currentlocation + turning_radius*perp_beweeg1;
            r_point2 = Currentlocation + turning_radius*perp_beweeg2;
        end
        
        %Functie bepaald wat de positie is het tijdelijke doel
        function [Temp_waypoint, Circlepoint] = tempwaypoint(Currentlocation, r_point, alpha, draai, Currentangle, l_recht)
        
                    [turning_radius, beweeg, r_point1, r_point2, Uiterste_punt, Sens_thres, length_objects] = standaardvar(Currentlocation, Currentangle);
                    hoek_current = atan2(Currentlocation(2) - r_point(2), Currentlocation(1) - r_point(1));

                    Angle = twee_pi(beweeg, r_point - Currentlocation);
                    
                    if  Angle < 180
                        Eindhoek  = hoek_current - alpha;
                    else 
                        Eindhoek =  hoek_current + alpha;
                    end
                    
                    
                    x_circle = r_point(1) + turning_radius*cos(Eindhoek);
                    y_circle = r_point(2) + turning_radius*sin(Eindhoek);
                    
                    Circlepoint = [x_circle y_circle];
                    
                    
                    %Bepaal de temporary waypoint
                    Cirkelvector = Circlepoint - r_point;
                    
                    if strcmp(draai,'links') == 1
                        richting_rechtelijn = [-Cirkelvector(2) Cirkelvector(1)];
                    elseif strcmp(draai,'rechts') == 1
                        richting_rechtelijn = [Cirkelvector(2) -Cirkelvector(1)];
                    else
                    end
                        
                    unit_rrl = richting_rechtelijn/norm(richting_rechtelijn);
                    Temp_waypoint = Circlepoint + l_recht*unit_rrl;
        end
        
        %Bereken de hoek v2 tegenover v1 met de klok mee.
        function [Angle] = twee_pi(v1, v2)
            %Bereken de hoek v2 tegenover v1 met de klok mee.
            ang = atan2(v1(1)*v2(2)-v2(1)*v1(2),v1(1)*v2(1)+v1(2)*v2(2));  
            Angle = mod(-180/pi * ang, 360);
        end
        




