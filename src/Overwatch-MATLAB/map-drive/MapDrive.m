classdef MapDrive
    properties (SetAccess = private)
    end
    
    methods
        % Constructor
        function Self = MapDrive()
        end
        
        % Mapping
        function [PWMDrive] = Map(~, DriveExcitation, ~) % CurrentAngle
            if abs(DriveExcitation) < Configuration.MapDriveBound
                PWMDriveRaw = 150;
            else
                if DriveExcitation > 0
                    PWMDriveRaw = 150 + Configuration.MapDriveOffset + ...
                        Configuration.MapDriveFOC*(DriveExcitation - Configuration.MapDriveBound) + ...
                        Configuration.MapDriveTOC*(DriveExcitation - Configuration.MapDriveBound)^3;
                else
                    PWMDriveRaw = 150 - Configuration.MapDriveOffset + ...
                        Configuration.MapDriveFOC*(DriveExcitation + Configuration.MapDriveBound) + ...
                        Configuration.MapDriveTOC*(DriveExcitation + Configuration.MapDriveBound)^3;
                end
            end
        
            PWMDrive = round(PWMDriveRaw);
        end
    end
end

