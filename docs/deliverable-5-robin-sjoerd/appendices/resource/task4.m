%% INIT
clc;close all;clear all;
Vmax=1;
tw = 0.5e-9;
l=1.2;
L0=0.5e-6;C0=2e-12;Zl=50+1i*50;
Z0=sqrt(L0/C0);
gamma=sqrt(L0*C0);
Gamma=(Zl-Z0)/(Zl+Z0);

%% PARAMETERS BODE PLOT
no_steps=10000;
no_steps_int=10000;
%create bode plot from omega=10^-1 to 10^9
omega=logspace(-1,11,no_steps);
omega_interesting=logspace(9,10,no_steps_int);
A = bodeoptions;
A.FreqScale='log';
A.PhaseVisible='off';
A.MagUnits='abs';
%params for interesting part
P = bodeoptions;
P.FreqScale='linear';
P.MagUnits='abs';
P.PhaseVisible='off';

%% BEGIN full bode overview
resp_bode=abs((pi*dirac(omega)+1./(1i*omega)).*(1-exp(1i*omega*tw)).*... %U_hat
    (exp(-1i*gamma.*omega*l) + Gamma*exp(1i*gamma.*omega*(l-2*l))) ./ (1+Gamma*exp(-2*1i*gamma.*omega*l))).^2;
sys = frd(resp_bode,omega);
figure(1)
bode(sys,A)

% Single graph
[y, x] = frdata(sys);
y = {y(:)};
x = {x};

LineStyle = {'-'};
LineColor = [1 0 0];
MarkerStyle = {'none'};
MarkerColor = [.75 .75 .75];
legendText = {'Response'};
makeLegend = 'yes';
legendLocation = 'northEast';
logX = 1;

% Config

%XTicks = -10:1:10;
%YTicks = -10:1:10;
outputPath = 'output/testGraph'; % 'off' to disable outputting
graphTitle = 'title';
yLabel = 'ylabel';
xLabel = 'xlabel';
xLim = [1 10^11];
yLim = 'auto';

uber_graph;


%% BEGIN interesting part
resp_interesting=abs((pi*dirac(omega_interesting) + 1./(1i*omega_interesting)) .* (1-exp(1i*omega_interesting*tw)).*... %U_hat
    (exp(-1i*gamma.*omega_interesting*l) + Gamma*exp(1i*gamma.*omega_interesting*(l-2*l))) ./ (1+Gamma*exp(-2*1i*gamma.*omega_interesting*l))).^2;

sys_int = frd(resp_interesting,omega_interesting);

figure(2)
bodeplot(sys_int,P)

%% POWER transferred to load
resp=@(omega) abs((pi*dirac(omega)+1./(1i*omega)).*(1-exp(1i*omega*tw)).*... %U_hat
    (exp(-1i*gamma.*omega*l) + Gamma*exp(1i*gamma.*omega*(l-2*l))) ./ (1+Gamma*exp(-2*1i*gamma.*omega*l))).^2;
Eout=integral(resp,1e-11,1e13)

Ein=Vmax^2*tw

efficiency=Eout/Ein*100

