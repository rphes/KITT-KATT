%Beacon location
beacon = [0.5 0.5];
% locations of microphones
X =[0 0 ;
    1 1 ;
    0 1 ;
    1 0];

N = size(X,1);

%calculate time differences
x_approx=[];
y_approx=[];
for M=1:1000
sigma=0.1;
for i=1:N
    for j=1:N
        x1 = norm(beacon-X(j,:),2);
        x2 = norm(beacon-X(i,:),2);
        R(i,j) = abs(x1-x2)+sigma*randn(1,1);
    end
end
 
x = tdoa(R,X);
x(1:2);
x_approx = [x_approx x(1)];
y_approx = [y_approx x(2)];
end
x_int = [mean(x_approx)-std(x_approx)/sqrt(M) mean(x_approx)+std(x_approx)/sqrt(M)]
y_int = [mean(y_approx)-std(y_approx)/sqrt(M) mean(y_approx)+std(y_approx)/sqrt(M)]