function butControl_callback(src, e)
    global connected;
    global controlling;
    global tracking;
    
    if ~connected 
        status_update('Must first connect');
    else
        if ~tracking
            status_update('First track');
        else
            if ~controlling
                controlling = 1;
                set(src,'String', 'STOP CONTROL <C>');
                status_update('Controlling');
            else
                controlling = 0;
                set(src,'String', 'CONTROL <C>');
                status_update('Stopped controlling');
            end
        end
    end                
end