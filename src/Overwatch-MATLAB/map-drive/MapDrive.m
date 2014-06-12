classdef MapDrive < handle
    properties (SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = MapDrive()
        end
        
        % Mapping
        function [PWMDrive] = Map(~, DriveExcitation, ~) % CurrentAngle
            if abs(DriveExcitation) < Configuration.DriveMapBound
                PWMDriveRaw = 150;
            else
                if DriveExcitation > 0
                    PWMDriveRaw = 150 + Configuration.DriveMapOffset + ...
                        Configuration.DriveMapFOC*(DriveExcitation - Configuration.DriveMapBound) + ...
                        Configuration.DriveMapTOC*(DriveExcitation - Configuration.DriveMapBound)^3;
                else
                    PWMDriveRaw = 150 - Configuration.MapDriveOffset + ...
                        Configuration.DriveMapFOC*(DriveExcitation + Configuration.DriveMapBound) + ...
                        Configuration.DriveMapTOC*(DriveExcitation + Configuration.DriveMapBound)^3;
                end
            end
        
            PWMDrive = round(PWMDriveRaw);
        end
    end
end

