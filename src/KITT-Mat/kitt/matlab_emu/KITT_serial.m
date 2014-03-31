% KITT emulation woot

function ret = KITT_serial(command, value)
    persistent walldist;
    persistent vel;
    persistent time;
    persistent force;
    persistent weight;

    % Open port
    if strcmp(command,'open')
        ret = 1;
        
        % Init
        walldist = 2.2;
        vel = 0;
        weight = .8;
        time = tic;
        force = 0;
        
        display '[KITT_emu] init';
    end
    
    % Write to port
    if strcmp(command,'transmit')
        pause(0.15);
        ret = '';
        
        % Update time
        dt = toc(time);
        time = tic;
        
        % Calculate acceleration
        res = weight*9.81*0.1;
        acc = force/weight;
        
        mayneg = 1;
        maypos = 1;
        
        if vel > 0.02
            acc = acc - res/weight;
            mayneg = 0;
        elseif vel < -0.02
            acc = acc + res/weight;
            maypos = 0;
        end

        % Calculate new position
        walldist = walldist - vel*dt - 0.5*acc*dt^2;
        
        % Calculate new velocity
        vel = vel + acc*dt;
        
        if (vel < 0) && ~mayneg
            vel = 0;
        elseif (vel > 0) && ~maypos
            vel = 0;
        end
        
        % Crash
        if walldist < 0
            walldist = 0;
            vel = 0;
        end 
        
        if strcmp(value{1}, 'status')
            ret = ['D111 111' char(10) 'U' num2str(round(walldist*100)) ' ' num2str(round(walldist*100)) char(10) 'A19500' char(10) 'Audio 1' char(10)];
        end
        
        if strcmp(value{1}, 'drive')
            val = value{2};
            
            if (val > 150)
                force = (val - 154)*0.35;
            end
            
            if (val < 150)
                force = (val - 146)*0.35;
            end
            
            if val == 150
                force = 0;
            end
                
            ret = '';
        end
    end
        
    
    % Close port
    if strcmp(command,'close')
        ret = 1;
    end
end