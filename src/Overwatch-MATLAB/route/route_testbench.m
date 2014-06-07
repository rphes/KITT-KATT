clear all
addpath(genpath('..'))

route = Route();

CurrentLocation = [0; 0];
CurrentAngle = pi*2;
Waypoint = [2; -2];
SensorData = [2 2];
CarDirection = [cos(CurrentAngle);sin(CurrentAngle)];

global TurningPoint
global TanPoint

[CurrentDistance, ReferenceAngle] = route.DetermineRoute(...
    CurrentLocation,...
    CurrentAngle,...
    Waypoint,...
    SensorData...
);

CarReferenceDirection = [cos(ReferenceAngle);sin(ReferenceAngle)];

StraightDistance = norm(CurrentLocation-Waypoint)
CurrentDistance

figure(1);
hold off
plot([CurrentLocation(1) CurrentLocation(1)+CarDirection(1)],[CurrentLocation(2) CurrentLocation(2)+CarDirection(2)],'-r');
hold on;
plot([CurrentLocation(1) CurrentLocation(1)+CarReferenceDirection(1)],[CurrentLocation(2) CurrentLocation(2)+CarReferenceDirection(2)],'-b');
plot(CurrentLocation(1),CurrentLocation(2),'o','MarkerSize',15,'MarkerEdgeColor','red','MarkerFaceColor','red');
plot(Waypoint(1),Waypoint(2),'o','MarkerSize',15,'MarkerEdgeColor','blue','MarkerFaceColor','blue');
plot(TurningPoint(1),TurningPoint(2),'o','MarkerSize',15,'MarkerEdgeColor','green','MarkerFaceColor','green');
plot(TanPoint(1),TanPoint(2),'o','MarkerSize',15,'MarkerEdgeColor',[1 1 0],'MarkerFaceColor',[1 1 0]);
legend({'Current location','Car reference direction','Reference direction','Waypoint','Turning point','Tangent point'});
hold off
grid on
xlabel 'x (m)';
ylabel 'y (m)';
xlim([-4 4]);
ylim([-4 4]);
title 'Virtual chamber';