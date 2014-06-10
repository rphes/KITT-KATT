classdef Configuration
    properties (Constant = true)
        SteeringFeedbackCoefficient = -.5; % Note: combines with MapSteerFOC. -1 is the deepest pole!
        
        FieldWidth = 7;
        FieldHeight = 7;
 
        DriveObserverPoles = -4.1;
        DriveCompensatorPoles = -0.5;
        
        MapDriveBound = 0.01
        MapDriveFOC = 3.25;
        MapDriveTOC = -0.015;
        MapDriveOffset = 6;
        
        CarTurningRadius = 0.65;
        CarLength = 0.35;
        CarWidth = 0.20;
        
        MapSteerBound = 0;
        MapSteerFOC = 50/asin(0.35/0.65);
        MapSteerTOC = 0;
        
        RouteThreshold = 1.5;
        RouteClearance = 1;
        RouteOverflowTime = 2;
        RouteOvershootThreshold = 0.2;
        
        PlotTimeFrame = 15;
        
        TDOARecordingTime = 0.2;
        TDOAImpulsePeakThreshold = 0.85;
        TDOASoundSpeed = 348;
        TDOATrimPeakFrequency = 8;
        TDOATrimSkipCoefficient = 0.85;
        TDOATrimPeakThreshold = 0.7;
        TDOATrimClearanceBefore = 1000;
        TDOATrimClearanceAfter = 1500; % 2000
        
        LocMics = [
            0   0;
            0   7;
            7   7;
            7   0;
            3.5 0
        ]
        LocPredictionFilterOrder = 1
        LocPredictionFilterMaximumDevitation = 1e99
        
        Fs = 48000;
    end
end

