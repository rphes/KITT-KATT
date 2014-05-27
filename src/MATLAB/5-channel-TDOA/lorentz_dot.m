function [res] = lorentz_dot(a,b)
    res = dot(a(1:length(a)-1),b(1:length(b)-1))-a(length(a))*b(length(b));
end