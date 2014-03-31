function loop()
    global tracking;
    global running;
    global controlling;
    global use_lpfilter;
    global use_pfilter;
    global sensor_mode;
    global labBat;
    global labTime;
    global labSampleTime;
    global labProcTime;
    global lDistRight;
    global lDistLeft;
    global lDistFilt;
    global lDistRef;
    global lDistInt;
    global aDist;
    global lExPWM;
    global aExPWM;
    global lExForce;
    global aExForce;
    global sRef;
    global sBound;
    global sFOC;
    global sTOC;
    global want_to_disconnect;
    global butConnect;
    global butConnectBusy;
    global A;
    global B;
    global C;
    global L;
    global K;
    global SnapData;
    
    SnapData.batteryVoltage = nan;
    resetted = 0;
    
    low_pass_filter = LowPassFilter(Cfg.LowPassFallOff,Cfg.LowPassTimeStep);
    pred_filter = PredictionFilter(Cfg.PredDeviation);
    
    calculate_model();

    while running        
        % Check for disconnect
        if want_to_disconnect
        	set(butConnect,...
                'String','DISCONNECTING...',...
                'Enable','Off'...
                );
            drawnow
            
            KITT_serial('close');

            set(butConnect,...
                'String','CONNECT <K>',...
                'Enable','On'...
                );
            
            want_to_disconnect = 0;
            butConnectBusy = 0;
            
            status_update('Disconnected');
        end

        if ~tracking
            drawnow
            pause(0.5)
            resetted = 0;
        else
            % If this is the first iteration, apply resets
            if ~resetted
                resetted = 1;
                
                % Reset
                states = [];
                dists = [];
                ex = [];
                pwm = [];
                i = 0;
                reset_line(lDistLeft);
                reset_line(lDistRight);
                reset_line(lDistRef);
                reset_line(lDistInt);
                reset_line(lDistFilt);
                reset_axes(aDist);
                reset_line(lExPWM);
                reset_axes(aExPWM);
                reset_line(lExForce);
                reset_axes(aExForce);
                time = tic;
                sample_time = tic;
            end
            
            %% Initialize
            drawnow
            i = i+1;
            status = KITT_status(KITT_serial('transmit',{'status'}));
            cur_time = toc(time);
            cur_sample_time = toc(sample_time);
            proc_time = tic;
            sample_time = tic;
            cur_ref = get(sRef,'Value');
            
            % Sensor mode
            if sensor_mode == SensorMode.LEFT
                dist = status.distanceLeft;
            elseif sensor_mode == SensorMode.RIGHT
                dist = status.distanceRight;
            else
                if status.distanceRight > status.distanceLeft
                    dist = status.distanceRight;
                else
                    dist = status.distanceLeft;
                end
            end
            
            % Apply filters
            if use_pfilter
                dist = pred_filter.eval(dists,dist);
            end
            if use_lpfilter
                dist = low_pass_filter.eval(dists,dist);
            end
            
            dists(i) = dist;
            
            %% Process
            dt = cur_sample_time; % Time step
            x_ref = [cur_ref;0]; % Reference vector
            y = dist; % Distance read
            
            % Current state
            if i == 1
                x = [0;0]; % Initalization
            else
                x = states(:,i-1); % Previous state
            end

            % Solve using ODE45
            options = odeset('RelTol',10e-8,'AbsTol',[10e-8 10e-8]);
            if controlling
                [t_solved, x_solved] = ode45(@(t,x_in) (A-B*K-L*C)*x_in+B*K*x_ref+L*y,[0 dt],x,options);
            else
                [t_solved, x_solved] = ode45(@(t,x_in) (A-L*C)*x_in+L*y,[0 dt],x,options);
            end
           
            cur_x = x_solved(length(t_solved),:)'; % Get state
            states(:,i) = cur_x; % Save state

            %% Mapping
            if controlling
                ex(i) = K*(cur_x-x_ref); % Save excitation
                
                map_bound = get(sBound, 'Value'); % Mapping bound
                map_foc = get(sFOC, 'Value'); % Mapping first order coefficient
                map_toc = get(sTOC, 'Value'); % Mapping third order coefficient

                % Find mapping
                if abs(ex(i)) < map_bound
                    cur_pwm_unrounded = 150;
                else
                    if ex(i) > 0
                        cur_pwm_unrounded = 156 + map_foc*(ex(i)-map_bound) + map_toc*(ex(i)-map_bound)^3;
                    else
                        cur_pwm_unrounded = 144 + map_foc*(ex(i)+map_bound) + map_toc*(ex(i)+map_bound)^3;
                    end
                end

                pwm(i) = round(cur_pwm_unrounded); % Save
            else
                ex(i) = 0;
                pwm(i) = 150;
            end
            
            % Drive KITT
            KITT_serial('transmit',{'drive', pwm(i)});
            
            cur_proc_time = toc(proc_time);
            
            % Save
            SnapData.batteryVoltage = status.batteryVoltage;
            
            %% Update GUI
            set(labBat.text,'String',['Battery voltage: ' num2str(round(status.batteryVoltage*100)/100) 'V']);
            set(labTime.text,'String',['Time: ' num2str(round(cur_time*100)/100) 's']);
            set(labSampleTime.text,'String',['Sample time: ' num2str(round(cur_sample_time*1000)) 'ms']);
            set(labProcTime.text,'String',['Processing time: ' num2str(round(cur_proc_time*1000)) 'ms']);
            add_line_point(lDistLeft, cur_time, status.distanceLeft);
            add_line_point(lDistRight, cur_time, status.distanceRight);
            add_line_point(lDistRef, cur_time, cur_ref);
            add_line_point(lDistInt, cur_time, cur_x(1));
            add_line_point(lDistFilt, cur_time, dist);
            shift_axes(aDist, cur_time);
            
            % Make PWM graph a stair
            if (i > 1)
                add_line_point(lExPWM, cur_time-0.001, pwm(i-1));
            else
                add_line_point(lExPWM, cur_time-0.001, 0);
            end
            
            add_line_point(lExPWM, cur_time, pwm(i));
            shift_axes(aExPWM, cur_time);
            add_line_point(lExForce, cur_time, ex(i));
            shift_axes(aExForce, cur_time);
            drawnow
        end
    end
    
    % Delete window object
    delete(1);
end