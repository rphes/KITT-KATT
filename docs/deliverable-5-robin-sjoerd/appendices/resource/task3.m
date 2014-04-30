L0=0.5e-6;C0=2e-12;Zl=100;
Z0=sqrt(L0/C0);
zmin=0;zmax=1.2;tmin=0;tmax=5e-9;
gamma=sqrt(L0*C0);
Gamma=(Zl-Z0)/(Zl+Z0);
aantal_punten_z=800;aantal_punten_t=100;
Data_V=[];Data_I=[zeros(aantal_punten_z+1, aantal_punten_t+1)];
for i=aantal_punten_z:-1:0
    for j=aantal_punten_t:-1:0
        Data_V(i+1,j+1)=V(i*zmax/aantal_punten_z, j*tmax/aantal_punten_t);
    end
end
Bscan_plot(tmin:tmax/aantal_punten_t:tmax, zmin:zmax/aantal_punten_z:zmax , Data_V , 'Time [s]' , 'Distance in transmission line [m]' , 'V(z,t)')

for i=aantal_punten_z:-1:0
    for j=aantal_punten_t:-1:0
        for k=i:-1:0
            if j~=aantal_punten_t
                Data_I(i+1,j+1) = Data_I(i+1,j+1) - C0*(1/aantal_punten_z)*((Data_V(k+1,j+2) - Data_V(k+1,j+1)) / (tmax/aantal_punten_t));
            end
        end
    end
end
Bscan_plot(tmin:tmax/aantal_punten_t:tmax, zmin:zmax/aantal_punten_z:zmax , Data_I , 'Time [s]' , 'Distance in transmission line [m]' , 'I(z,t)')
