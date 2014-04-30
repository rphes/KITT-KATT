function [waarde] = V(z, t)
L0=0.5e-6;C0=2e-12;Zl=100;
Z0=sqrt(L0/C0);
zmin=0;zmax=1.2;tmin=0;tmax=5e-9;
gamma=sqrt(L0*C0);
Gamma=(Zl-Z0)/(Zl+Z0);
l=zmax;
waarde = U(t-gamma*z)+Gamma*U(t+gamma*(z-2*l))-Gamma*U(t-gamma*(z+2*l))-Gamma^2*U(t+gamma*(z-4*l));
end
