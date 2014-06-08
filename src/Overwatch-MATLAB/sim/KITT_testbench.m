clear all

% Init
Model = KITT();
SimulationTime = 10;
StepTime = 0.1;
BeginTime = tic;


hold off;

% Loop
dist = [];
N = 1000;
ext = 2;
for i = 1:N
    if i > 200
        ext = -1;
    end
    
    if i > 500
        ext = 0.5;
    end
    
    [dist(i), ~] = Model.IterateDistance(ext, 0.1);
end

plot(dist)
