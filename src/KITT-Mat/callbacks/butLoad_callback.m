function butLoad_callback(src, e)
    global sFOC;
    global sTOC;
    global sBound;
    global sWeight;
    global sRes;
    global sPoles;
    global snaps;
    global SnapData;
    
    snap.found = 0;
    cur_bat = SnapData.batteryVoltage;
    
    % Check for nan profile
    if isnan(cur_bat)
    	for i = 1:length(snaps)
            if isnan(snaps{i}.id)
                snap = snaps{i};
                snap.found = 1;
            end
        end
    else
        % Find best matching profile
        best_diff = nan; % Large difference
        
        for i = 1:length(snaps)
            if isnan(best_diff) || (abs(snap.bat-cur_bat) > abs(snaps{i}.bat-cur_bat))
                snap = snaps{i};
                snap.found = 1;
            end
        end
    end  
            
    if ~snap.found
        display '[SNAPSHOT] Could not find matching snapshot';
        status_update('No matching snapshot');
    else
        display(['[SNAPSHOT] Snapshot at level ' num2str(snap.id) ' loaded']);
        status_update('Best fit loaded');
        % Set sliders
        set(sFOC, 'Value', snap.FOC);
        set(sTOC, 'Value', snap.TOC);
        set(sBound, 'Value', snap.bound);
        set(sWeight, 'Value', snap.weight);
        set(sRes, 'Value', snap.res);
        set(sPoles, 'Value', snap.poles);

        % Call callbacks
        drawnow
    end
end