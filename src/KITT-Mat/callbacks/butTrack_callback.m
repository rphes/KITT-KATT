function butTrack_callback(src, e)
    global connected;
    global controlling;
    global tracking;
    global butControl;
    
    if ~connected
        status_update('Must first connect');
    else
        if ~tracking
            tracking = 1;
            set(src,'String', 'STOP TRACKING <T>');
            status_update('Tracking');
        else
            tracking = 0;
            set(src,'String', 'TRACK <T>');
            controlling = 0;
            set(butControl,'String', 'CONTROL <C>');
            status_update('Stopped tracking');
        end
    end
end