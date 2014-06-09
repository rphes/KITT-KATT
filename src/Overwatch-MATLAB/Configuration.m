classdef Configuration
    properties (Constant = true)
        SteeringFeedbackCoefficient = -.5;
        % Note: combines with MapSteerFOC. -1 is the deepest pole!
        
        % Field dimensions
        XMax = 10;
        YMax = 10;
 
        DriveCarWeight = 0.15;
        DriveRollingCoefficient = 0.05;
        DriveObserverPoles = -4.1;
        DriveCompensatorPoles = -0.5; % -1.3
        
        MapDriveBound = 0.005
        MapDriveFOC = 3.25;
        MapDriveTOC = -0.015;
        MapDriveOffset = 6;
        
        CarTurningRadius = 0.65;
        CarLength = 0.35;
        CarWidth = 0.20;
        
        % Measured turning radius: 0.65 m
        % Measured length of car: 0.35 m
        % PWM range: 100 (utmost left) - 150 (middle) - 200 (utmost right)
        % PWM deviation: 50
        
        MapSteerBound = 0;
        MapSteerFOC = 50/asin(0.35/0.65);
        MapSteerTOC = 0;
        
        RouteThreshold = 1;
        RouteClearance = 0.5;
        
        % Plot stuff
        PlotTimeFrame = 15;
    end
end

