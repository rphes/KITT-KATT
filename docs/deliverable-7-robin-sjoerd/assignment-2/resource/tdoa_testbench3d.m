%Beacon location
beacon = [2 2 2];
% locations of microphones
X =[0 0 0 ;
    1 1 0;
    0 1 1;
    1 0 1;
    1 0 0]*4;

N = size(X,1);

%calculate time differences
x_approx=[];
y_approx=[];
z_approx=[];
for M=1:100
sigma=0.5;
for i=1:N
    for j=1:N
            x1 = norm(beacon-X(j,:),2);
            x2 = norm(beacon-X(i,:),2);
            R(i,j) = abs(x1-x2)+sigma*randn(1,1);
    end
end
 
x = tdoa(R,X);
x_approx = [x_approx x(1)];
y_approx = [y_approx x(2)];
z_approx = [z_approx x(3)];
end

%calculate 95% confidence intervals
x_int = [mean(x_approx)-1.96*std(x_approx)/sqrt(M) mean(x_approx)+1.96*std(x_approx)/sqrt(M)]
y_int = [mean(y_approx)-1.96*std(y_approx)/sqrt(M) mean(y_approx)+1.96*std(y_approx)/sqrt(M)]
z_int = [mean(z_approx)-1.96*std(z_approx)/sqrt(M) mean(z_approx)+1.96*std(z_approx)/sqrt(M)]
% std(x_approx)