function [waarde] = U(t)
L0=0.5e-6;C0=2e-12;Zl=100;
Z0=sqrt(L0/C0);
zmin=0;zmax=1.2;tmin=0;tmax=5e-9;
gamma=sqrt(L0*C0);
Gamma=(Zl-Z0)/(Zl+Z0);
if (t>0 && t<0.5e-9)
    waarde=1;
else
    waarde=0;
end
end

    