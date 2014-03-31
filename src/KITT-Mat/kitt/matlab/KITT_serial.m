function ret = KITT_serial(command, value)
    persistent handler;
    persistent drive;
    persistent steer;
    persistent verbose;
    % Open port
    if strcmp(command,'open')
        done = 0;
        attempt = 1;
        
        while ~done
            if ~isempty(instrfindall)
                fclose(instrfindall);
                delete(instrfindall);
            end

            display(['[KITT_serial] Opening port (attempt: ' int2str(attempt) ')']);

            handler = serial(value);
            handler.InputBufferSize = 50000;
            handler.OutputBufferSize = 50000;
            handler.BaudRate = 115200;
            handler.DataBits = 8;
            handler.StopBits = 1;
            handler.Parity = 'none';
            handler.Terminator = 'LF';
            handler.Name = 'KITTCOM';

    %         com_port.FlowControl = 'hardware'
    %         com_port.RequestToSend = 'on';
    %         com_port.DataTerminalReady = 'off';

            % Initialize variables
            drive = 150;
            steer = 150;
            verbose = 1;

            try
                drawnow
                fopen(handler);
                done = 1;
                ret = 1;
                display(['[KITT_serial] Connected']);
            catch MExc
                ret = 0;
                attempt = attempt + 1;
                
                if attempt > 5
                    done = 1;
                    display(['[KITT_serial] Failed to connect']);
                end
            end 
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
            fwrite(handler, [kitt_command char(10)]);

            % Reading recieved data
            eom = 1; % End of message
            message = zeros(1,32);
            i = 0;
            while eom
                drawnow
                chr = fread(handler, 1);
                i = i+1;
                   
                % End of transmission characterized by ASCII 4 character
                if chr == 4
                    eom = 0;
                else
                    message(i) = chr;
                end
            end
            
            if verbose
                display(['[KITT_serial] Received ' int2str(i) ' bytes']);
            end

            % Remove trailing zeros
            message = message(1:find(message,1,'last'));

            ret = char(message);
        else
            ret = 0;
        end
    end
    
    % Close port
    if strcmp(command,'close')
        display '[KITT_serial] Closing port'
        
        try
            drawnow
            fclose(handler);
            ret = 1;
        catch MExc
            ret = 0;
            display '[KITT_serial] Could not disconnect';
        end
    end
    
    % Set verbose
    if strcmp(command,'verbose')
        verbose = value;
    end
end