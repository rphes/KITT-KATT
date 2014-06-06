classdef Configuration
    properties (Constant = true)
        SteeringFeedbackCoefficient = -1;
        
        DriveCarWeight = 0.16;
        DriveRollingCoefficient = 0.08;
        DriveObserverPoles = -4.1;
        DriveCompensatorPoles = -1.3;
        
        DriveMapBound = 0.02;
        DriveMapFOC = 3.23;
        DriveMapTOC = -0.0114;
        DriveMapOffset = 6;
        
        % Measured turning radius: 0.65 m
        % Measured length of car: 0.35 m
        % PWM range: 100 (utmost left) - 150 (middle) - 200 (utmost right)
        % PWM deviation: 50
        
        SteerMapBound = 0;
        SteerMapFOC = 50/asin(0.35/0.65);
        SteerMapTOC = 0;
    end
end

