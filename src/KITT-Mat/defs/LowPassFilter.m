classdef LowPassFilter
    properties (SetAccess = private)
        c1
        c2
        c3
    end
    
    methods
        function self = LowPassFilter(freq, dt)
            a = 1/(2*pi*freq*dt);
            self.c1 = (2*a^2+2*a)/(a^2+2*a+1);
            self.c2 = -a^2/(a^2+2*a+1);
            self.c3 = 1/(a^2+2*a+1);
        end
        
        function ret = eval(self, data, new_value)
            ret = new_value*self.c3;
            
            if length(data) >= 1
                ret = ret + data(length(data))*self.c1;
            end
            
            if length(data) >= 2
                ret = ret + data(length(data)-1)*self.c2;
            end
        end
    end
end

