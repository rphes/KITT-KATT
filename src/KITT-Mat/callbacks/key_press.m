% Handle key-press events
function key_press(src, e)
    global butConnect;
    global butTrack;
    global butControl;
    global butSensor;
    global butLPFilter;
    global butPFilter;
    
	switch e.Key
        % Key-press callbacks
        case 'k'
            butConnect_callback(butConnect, []);
            
        case 't'
            butTrack_callback(butTrack, []);
            
        case 'c'
            butControl_callback(butControl, []);
            
        case 's'
            butSensor_callback(butSensor, []);
            
        case 'l'
            butLPFilter_callback(butLPFilter, []);
            
        case 'p'
            butPFilter_callback(butPFilter, []);
	end
end