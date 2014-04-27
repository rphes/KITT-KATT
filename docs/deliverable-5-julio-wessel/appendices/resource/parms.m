function [c1, c3] = parms(Z0, Zl, Zin, f, v)
    gamma=1/v;
    b = 2*pi*f*gamma;

    a = (Zin*Z0-Zl*Z0)/(Z0^2-Zin*Zl);
    q = (1+a)/(1-a);
    c1 = angle(q)/(2*b);
    c3 = pi/b;
end