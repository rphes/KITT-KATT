
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
        propbeginpunt
        propeindpunt 
        
        %Dit zijn properties om functie lr_object te testen
        propCirclepoint
        propr_point2
        
        
        
        %Dit zijn properties die daadwerkelijk gebruikt worden
        propTemp_waypoint
        propObjectlocation
        
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
            Self.propbeginpunt = [0 0];
            Self.propeindpunt = [0 0]; 
            
            Self.propObjectlocation = [];
            Self.propTemp_waypoint = [100 100];
        end
        
        
        
        
        % Determine route
        function [CurrentDistance, ReferenceAngle] = DetermineRoute(Self, Currentlocation, Currentangle, Waypoints, Sensors, Steering)
                
                Distance_CW = norm(Currentlocation - Self.propTemp_waypoint);
                [turning_radius, beweeg, r_point1, r_point2, Uiterste_punt, Sens_thres, length_objects] = standaardvar(Currentlocation, Currentangle);
                
                if Distance_CW < 1/50
                    Self.propTemp_waypoint = [100 100];
                end
                
                
                if Self.propTemp_waypoint(1) > 0 && Self.propTemp_waypoint(1) < Uiterste_punt(1) 
                    if Self.propTemp_waypoint(2) > 0 && Self.propTemp_waypoint(2) < Uiterste_punt(2)
                        Waypoints = Self.propTemp_waypoint
                    end
                end
                    
                    
                
                
                
                if Sensors(1) < Sens_thres && Sensors(2) < Sens_thres && Steering == 150
                    draai = 'dunno';
                    
                    [tempwaypoint, Objeclocation] = TEMPway(Currentlocation, Currentangle, Uiterste_punt, r_point1, r_point2, draai);
                    Self.propTemp_waypoint = tempwaypoint;
                    Self.propObjectlocation = [Self.propObjectlocation Objeclocation];
                    
                    [CurrentDistance, ReferenceAngle, r_point, alpha, l_recht] = bereken_outputs(Self, Currentlocation, Currentangle, tempwaypoint);
                    
                    test_lengths(Self, alpha, Currentlocation, r_point, beweeg, turning_radius, tempwaypoint, l_recht);
                    
                elseif Sensors(1) < 0.9 && Steering == 150
                    draai = 'rechts';
                    
                    [tempwaypoint, Objeclocation] = TEMPway(Currentlocation, Currentangle, Uiterste_punt, r_point1, r_point2, draai);
                    Self.propObjectlocation = [Self.propObjectlocation Objeclocation];
                    
                    Self.propTemp_waypoint = tempwaypoint;
                    
                    [CurrentDistance, ReferenceAngle, r_point, alpha, l_recht] = bereken_outputs(Self, Currentlocation, Currentangle, tempwaypoint);
                    
                    test_lengths(Self, alpha, Currentlocation, r_point, beweeg, turning_radius, tempwaypoint, l_recht);
                    
                elseif Sensors(2) < 0.9 && Steering == 150
                    draai = 'links';
                    
                    [tempwaypoint, Objeclocation] = TEMPway(Currentlocation, Currentangle, Uiterste_punt, r_point1, r_point2, draai);
                    Self.propObjectlocation = [Self.propObjectlocation Objeclocation];
                    
                    Self.propTemp_waypoint = tempwaypoint;
                    
                    [CurrentDistance, ReferenceAngle, r_point, alpha, l_recht] = bereken_outputs(Self, Currentlocation, Currentangle, tempwaypoint);
                    
                    test_lengths(Self, alpha, Currentlocation, r_point, beweeg, turning_radius, tempwaypoint, l_recht);
                else
                    
                    [CurrentDistance, ReferenceAngle, r_point, alpha, l_recht] = bereken_outputs(Self, Currentlocation, Currentangle, Waypoints);
                
                
                     test_lengths(Self, alpha, Currentlocation, r_point, beweeg, turning_radius, Waypoints, l_recht);
                end
        end
        
        
        
        %Bereken Distance en Angle als er geen object is
        function [CurrentDistance, ReferenceAngle, r_point, alpha, l_recht] = bereken_outputs(Self, Currentlocation, Currentangle, Waypoints)
                    
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
        
        
        
        %Dit is om functie te testen   
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
                
                Self.propbeginpunt = beginpunt_lijn;
                Self.propeindpunt = eindpunt_lijn; 
                
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
        function [tempwaypoint, Objeclocation] = TEMPway(Currentlocation, Currentangle, Uiterste_punt, r_point1, r_point2, draai)
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
                [tempwaypoint, Objeclocation] = choose_longestwaypoint(snijvector1, snijvector2, Currentlocation, Currentangle);
            elseif strcmp(draai,'links') == 1 || strcmp(draai,'rechts') == 1
                
                [possible, waypoint, Objeclocation] = check_wanted_waypoint(draai, Currentlocation, Currentangle);
                
                if strcmp(possible,'true')
                    tempwaypoint = waypoint;
                elseif strcmp(possible,'false') == 1
                    [tempwaypoint, Objeclocation] = choose_longestwaypoint(snijvector1, snijvector2, Currentlocation, Currentangle);
                else
                    Error = 'Error'
                end
                
            else
                Error = 'Error'
            end
            
        end
        
        
        %Functie bepaald welke waypoint je moet kiezen
        function [tempwaypoint, Objeclocation] = choose_longestwaypoint(snijvector1, snijvector2, Currentlocation, Currentangle)
            [turning_radius, beweeg, r_point1, r_point2, Uiterste_punt, Sens_thres, length_objects] = standaardvar(Currentlocation, Currentangle);
            [tempw90, tempw270, Objeclocation] = tempwaypoints1(Currentlocation, Currentangle);
            afstand1 = norm(snijvector1);
            afstand2 = norm(snijvector2);
            
            if afstand1 > afstand2
                Angle = twee_pi(beweeg, snijvector1);
                if Angle < 180
                    tempwaypoint = tempw90;
                else
                    tempwaypoint = tempw270;
                end
            else
                Angle = twee_pi(beweeg, snijvector2);
                if Angle < 180
                    tempwaypoint = tempw90;
                else
                    tempwaypoint = tempw270;
                end
            end
        end
        
        %Functie bepaald wat de twee mogelijke waypoints zijn als beide
        %sensoren iets zien
        function [tempw90, tempw270, Objectlocation] = tempwaypoints1(Currentlocation, Currentangle)
            [turning_radius, beweeg, r_point1, r_point2, Uiterste_punt, Sens_thres, length_objects] = standaardvar(Currentlocation, Currentangle);
            Objectlocation = Currentlocation + Sens_thres*beweeg;
            
            perp_beweeg1 = [sin(Currentangle), -cos(Currentangle)]; 
            perp_beweeg2 = [-sin(Currentangle), cos(Currentangle)];
            
            tempw90 = Objectlocation + (turning_radius + length_objects)*perp_beweeg1;
            tempw270 = Objectlocation + (turning_radius + length_objects)*perp_beweeg2;
        end
        
        
        
        %Functie beslist of die kan draaien waar die naartoe wilt draaien
        function [possible, waypoint, Objeclocation] = check_wanted_waypoint(draai, Currentlocation, Currentangle)
        
            [turning_radius, beweeg, r_point1, r_point2, Uiterste_punt, Sens_thres, length_objects] = standaardvar(Currentlocation, Currentangle);
            [tempw90, tempw270, Objeclocation] = tempwaypoints2(Currentlocation, Currentangle);
      
            possible = 'true';
            
            if strcmp(draai,'rechts') == 1
                waypoint = tempw90;
            elseif strcmp(draai,'links') == 1
                waypoint = tempw270;
            else
                Error = 'Error'
            end
            
            N = 2*pi*2*turning_radius*1000; %Dit is hoeveel samples ik op de cirkel neem
            N = ceil(N);
            
            huidighoek = 0;
            delta_hoek = 2*pi/N;
            
            cx = waypoint(1);
            cy = waypoint(2);
            
            for loopvar = 1:N
                huidighoek = huidighoek + loopvar*delta_hoek;
            
                x = cx + 2*turning_radius*cos(huidighoek);
                y = cy + 2*turning_radius*sin(huidighoek);
                
                if x < 0 || x > Uiterste_punt(1)
                    possible = 'false';
                elseif y < 0 || y > Uiterste_punt(2)
                    possible = 'false';
                else
                end
            end
            
        end
        
        
        %Functie bepaald wat de twee mogelijke waypoints zijn als slechts 1
        %sensor iets ziet
        function [tempw90, tempw270, Objectlocation] = tempwaypoints2(Currentlocation, Currentangle)
            [turning_radius, beweeg, r_point1, r_point2, Uiterste_punt, Sens_thres, length_objects] = standaardvar(Currentlocation, Currentangle);
            Objectlocation = Currentlocation + Sens_thres*beweeg;
            
            perp_beweeg1 = [sin(Currentangle), -cos(Currentangle)]; 
            perp_beweeg2 = [-sin(Currentangle), cos(Currentangle)];
            
            tempw90 = Objectlocation + (turning_radius*1.5)*perp_beweeg1;
            tempw270 = Objectlocation + (turning_radius*1.5)*perp_beweeg2;
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
        
        
        %Dit zijn de variabelen die vaak in andere function worden gebruikt
        function [turning_radius, beweeg, r_point1, r_point2, Uiterste_punt, Sens_thres, length_objects] = standaardvar(Currentlocation, Currentangle)
            %Dit zijn de variabelen die vaak in andere function worden
            %gebruikt
            turning_radius = 0.7;
            Uiterste_punt = [20 20];
            Sens_thres = 0.9;
            length_objects = 0.5;
            
            beweeg = [cos(Currentangle), sin(Currentangle)];
            
            
            %Bereken r_point met parameterisering
            perp_beweeg1 = [sin(Currentangle), -cos(Currentangle)]; 
            perp_beweeg2 = [-sin(Currentangle), cos(Currentangle)];

            r_point1 = Currentlocation + turning_radius*perp_beweeg1;
            r_point2 = Currentlocation + turning_radius*perp_beweeg2;
        end

        %Bereken de hoek v2 tegenover v1 met de klok mee.
        function [Angle] = twee_pi(v1, v2)
            %Bereken de hoek v2 tegenover v1 met de klok mee.
            ang = atan2(v1(1)*v2(2)-v2(1)*v1(2),v1(1)*v2(1)+v1(2)*v2(2));  
            Angle = mod(-180/pi * ang, 360);
        end
        




