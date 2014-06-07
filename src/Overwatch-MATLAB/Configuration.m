classdef Configuration
    properties (Constant = true)
        SteeringFeedbackCoefficient = -4;
        
        % Field dimensions
        XMax = 10;
        YMax = 10;
 
        DriveCarWeight = 0.16;
        DriveRollingCoefficient = 0.08;
        DriveObserverPoles = -4.1;
        DriveCompensatorPoles = -1.3;
        
        MapDriveBound = 0; %0.02
        MapDriveFOC = 3.23;
        MapDriveTOC = -0.0114;
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

