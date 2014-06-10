classdef Loc < handle
    properties (SetAccess = private)
        locations
    end
    
    methods
        % Constructor
        function Self = Loc(InitialLocation)
            Self.locations = PredictionFilter(Configuration.LocPredictionFilterMaximumDevitation, Configuration.LocPredictionFilterOrder);
            Self.locations.Evaluate(InitialLocation);
        end
        
        % Processing function
        function [CurrentLocation, DoObserve] = Localize(Self, RangeDiff)
            NewLocation = Localize(RangeDiff, Configuration.LocMics)
            
            if isempty(NewLocation)
                DoObserve = 0;
            else
                DoObserve = 1;
                Self.locations.Evaluate(NewLocation);
            end
            
            % Get last location
            CurrentLocation = Self.locations.Data(size(Self.locations.Data,1),:)';
        end
    end
end