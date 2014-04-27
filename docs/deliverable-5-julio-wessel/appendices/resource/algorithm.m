% Data
Z0 = 50;
Zl = 100;
Zin = [26.5-10.4j 73.6+35.8j 39.1+29.3j];
f= [9.65e9 9.85e9 10e9];
e = 2.205;
c0 = 3e8;

% Initialization
v = c0/sqrt(e);
N = length(Zin);
l_max = 3;

a = [];
b = [];

% Find all parameters
for i = 1:N
    [a(i), b(i)] = parms(Z0, Zl, Zin(i), f(i), v);
end

% Find inital value set
a1 = a(2);
b1 = b(2);
k1 = ceil(-a1/b1);
kn = floor((l_max-a1)/b1);

err_best = 100;
l_best = 0;

for k = k1:kn
    % Calculate all best fits
    l = a1+k*b1;
    
    err = 0;
    for i = 1:N
        err = err + abs(  l-(a(i)+b(i)*round( (l-a(i))/b(i) ))  );
    end
    
    if err < err_best
        l_best = l;
        err_best = err;
    end
end

l_best
