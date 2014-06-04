%% This is a class calling all other functions in the right order

classdef Route
    
    properties(GetAccess = 'public', SetAccess = 'private')
        ref_hoek = 0;
        distance = 0;
        x0_loc;
        y0_loc;
        x_loc;
        y_loc;
        waypoints;
    end
    
    
    
    methods
        
        function obj = Route
            obj.x0_loc = 0;
            obj.y0_loc = 0;
            obj.x_loc = 0;
            obj.y_loc = 0;
            obj.waypoints = [0, 0];
        end
        
        function obj = stop(obj, wer)
            obj.x0_loc = wer;
        end
    end
    
    
end
