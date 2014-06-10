classdef Wrapper < handle
    properties (SetAccess = private)
        % TDOA determination
        tdoa
        
        % Routing
        route
        
        % Localization
        loc
        ang
        
        % Controlling
        ssSteer
        ssDrive
        
        % Mapping
        mapSteer
        mapDrive
        
        % Locations
        currentLocation
        microphoneLocations
    end
    
    methods
        % Constructor
        function Self = Wrapper(InitialLocation, InitialAngle, MicrophoneLocations)
            % Initialize all objects
            Self.tdoa = TDOA();
            Self.route = Route();
            Self.loc = Loc(InitialLocation);
            Self.ang = Angle(InitialLocation, InitialAngle);
            Self.ssSteer = SsSteer();
            Self.ssDrive = SsDrive();
            Self.mapSteer = MapSteer();
            Self.mapDrive = MapDrive();
            
            Self.currentLocation = InitialLocation;
            Self.microphoneLocations = MicrophoneLocations;
            
            Self.tdoa.RetrieveDeconvolutionMatrix();
        end
        
        % Looping function
        function Ret = Loop(Self)
            % Global variables set by C#
            global sensor_l
            global sensor_r
            global battery
            global waypoint
            
            % Global variables to set
            global loc_x
            global loc_y
            global angle
            global speed
            global pwm_steer
            global pwm_drive
            
            % Localization
            [Self.currentLocation, DoObserve] = Self.loc.Localize(Self.tdoa.GetRangeDiffMatrix());
            
            % Determine current angle
            CurrentAngle = Self.ang.DetermineAngle(Self.currentLocation);
            
            % Process route
            [CurrentDistance, ReferenceAngle] = Self.route.DetermineRoute(Self.currentLocation, CurrentAngle, waypoint, [sensor_l sensor_r]);
            
            % Call controllers
            ReferenceDistance = 0;
            [DriveExcitation, CurrentSpeed, ~] = Self.ssDrive.Iterate(CurrentDistance, ReferenceDistance, battery, DoObserve);
            [SteerExcitation] = Self.ssSteer.Iterate(CurrentAngle, ReferenceAngle, battery);
            
            % Excitation mapping
            [PWMDrive] = Self.mapDrive.Map(DriveExcitation, CurrentAngle);
            [PWMSteer] = Self.mapSteer.Map(SteerExcitation);
            
            % Set
            loc_x = Self.currentLocation(1);
            loc_y = Self.currentLocation(2);
            angle = CurrentAngle;
            speed = CurrentSpeed;
            pwm_steer = PWMSteer;
            pwm_drive = PWMDrive;
            
            debug;
            
            Ret = 1;
        end
    end
end