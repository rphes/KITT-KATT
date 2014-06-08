clear all

% Init
Model = KITT();
SimulationTime = 10;
StepTime = 0.1;
BeginTime = tic;


hold off;

% Loop
while toc(BeginTime) < SimulationTime
    pause(StepTime);
    
    % Iterate
    [Position, Speed] = Model.Iterate(156, 180);
    
    clc;
    Position
    
    figure(1);
    plot(Position(1), Position(2), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'red');
    hold on;
    xlabel 'x (m)';
    ylabel 'y (m)';
    xlim([-10 10]);
    ylim([-10 10]);
    title 'KITT simulator test';
    grid on;
end
% dist = [];
% N = 1000;
% ext = 2;
% for i = 1:N
%     if i > 200
%         ext = -1;
%     end
%     
%     if i > 500
%         ext = 0.5;
%     end
%     
%     [dist(i), ~] = Model.IterateDistance(ext, 0.1);
% end
% 
% plot(dist)
