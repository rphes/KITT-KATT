function ret = KITT_serial(command, value)
    persistent drive;
    persistent steer;
    persistent verbose;
    % Open port
    if strcmp(command,'open')
        done = 0;
        attempt = 1;
        
        while (~done) && (attempt <= 5)
            if ~isempty(instrfindall)
                fclose(instrfindall);
                delete(instrfindall);
            end

            display(['[KITT_serial] Opening port (attempt: ' int2str(attempt) ')']);
            
            drawnow
            if (EPOCommunications('open','/dev/tty.RNBT-3217-RNI-SPP'))
                ret = 1;
                done = 1;
            else
                ret = 0;
                done = 0;
                attempt = attempt + 1;
            end
        end
        
        steer = 150;
        drive = 150;
        
        if ret
            display(['[KITT_serial] Connected']);
        else
            display(['[KITT_serial] Failed to connect']);
        end
    end
    
    % Write to port
    if strcmp(command,'transmit')
        valid_command = 1;
        kitt_command = '';
        skip = 0;
        
        if strcmp(value{1}, 'status')
            % Retrieve status
            kitt_command = 'S';
        elseif strcmp(value{1}, 'drive')
            if round(value{2}) == drive
                skip = 1;
            else
                % Adjust driving speed
                drive = round(value{2});
                kitt_command = ['D' int2str(steer) ' ' int2str(drive)];
            end
        elseif strcmp(value{1}, 'steer')
            if round(value{2}) == steer
                skip = 1;
            else
                % Adjust steering angle
                steer = round(value{2});
                kitt_command = ['D' int2str(steer) ' ' int2str(drive)];
            end
        elseif strcmp(value{1}, 'audio')
            % Enable/disable audio
            kitt_command = ['A' int2str(value{2})];
        elseif strcmp(value{1}, 'raw')
            % Raw command
            kitt_command = value{2};
        else
            display '[KITT_serial] Invalid command';
            valid_command = 0;
        end
        
        if valid_command && ~skip
            if verbose
                display(['[KITT_serial] Writing to port "' kitt_command '"']);
            end
            
            drawnow
            ret = EPOCommunications('transmit',[kitt_command char(10)]);
        else
            ret = 0;
        end
    end
    
    % Close port
    if strcmp(command,'close')
        display '[KITT_serial] Closing port'
        
        if (EPOCommunications('close'))
            ret = 1;
        else
            ret = 0;
            display '[KITT_serial] Could not disconnect';
        end
    end
    
    % Set verbose
    if strcmp(command,'verbose')
        verbose = value;
    end
end