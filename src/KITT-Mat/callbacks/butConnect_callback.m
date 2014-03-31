function butConnect_callback(src, e)
    global connected;
    global butConnectBusy;
    global controlling;
    global tracking;
    global butTrack;
    global butControl;
    global want_to_disconnect;
    
    % This callback can be triggered while it's still
    % executing, therefore a busy construction
    if butConnectBusy == 0  
        butConnectBusy = 1;
        
        if connected == 0
            set(src,...
                'String','CONNECTING...',...
                'Enable','Off'...
                );
            
            drawnow
            
            if KITT_serial('open','/dev/tty.RNBT-3217-RNI-SPP')
                KITT_serial('verbose',0);
                set(src,...
                    'String','DISCONNECT <K>',...
                    'Enable','On'...
                    );
                connected = 1;
                want_to_disconnect = 0;
                
                status_update('Connected');
            else
                set(src,...
                    'String','CONNECT <K>',...
                    'Enable','On'...
                    );
                connected = 0;

                status_update('Failed to connect');
            end

            butConnectBusy = 0;
        else
            % Stop controlling
            controlling = 0;
            set(butControl, 'String', 'CONTROL <C>');
            
            % Stop tracking
            tracking = 0;
            set(butTrack,'String', 'TRACK <T>');
            
            % Disconnect
            connected = 0;
            set(src,...
                'String','WAITING...',...
                'Enable','Off'...
                );
            want_to_disconnect = 1;
        end
    end
end