function [c1, c3] = cab_len(Z0, Zl, Zin, f, v, found_length)
    gamma=1/v;
    b = 2*pi*f*gamma;

    % For checks!
    % a = (Zin*Z0-Zl*Z0)/(Z0^2-Zin*Zl);
    % q = (1+a)/(1-a);
    % l_check = (log(abs(q)) + 2*pi*k*1j + angle(q)*1j)/(2*b*1j)

    a = (Zin*Z0-Zl*Z0)/(Z0^2-Zin*Zl);
    q = (1+a)/(1-a);
    c1 = angle(q)/(2*b);
    c2 = -log(abs(q))/(2*b); % Heel klein!
    c3 = pi/b;
    
    % For checks
    % Z0*(Zl+1j*Z0*tan(b*l))/(Z0+1j*Zl*tan(b*l))
end