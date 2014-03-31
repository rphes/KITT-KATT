classdef PredictionFilter
    properties (SetAccess = private)
        dev_max
    end
    
    methods
        function self = PredictionFilter(dev_max)
            self.dev_max = dev_max;
        end
        
        function ret = eval(self, data, new_value)
            if (length(data) < 3)
                ret = new_value;
            else
                pred = 5/2*data(length(data))-2*data(length(data)-1)+1/2*data(length(data)-2);
                
                if (abs(pred-new_value) > self.dev_max)
                    ret = pred;
                else
                    ret = new_value;
                end
            end
        end
    end
end

