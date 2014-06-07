classdef Testclass < handle
    properties (SetAccess = private)
        prop
    end
    
    methods
        function Self = Testclass()
        end
        
        function SetProp(Self, Val)
            Self.prop = Val;
        end
        
        function [Ret] = GetProp(Self)
            Ret = Self.prop;
        end
    end
end