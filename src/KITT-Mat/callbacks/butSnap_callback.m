function butSnap_callback(src, e)
    global sFOC;
    global sTOC;
    global sBound;
    global sWeight;
    global sRes;
    global sPoles;
    global snaps;
    global SnapData;
    
    FOC = get(sFOC, 'Value');
    TOC = get(sTOC, 'Value');
    bound = get(sBound, 'Value');
    weight = get(sWeight, 'Value');
    poles = get(sPoles, 'Value');
    res = get(sRes, 'Value');
    bat = SnapData.batteryVoltage;
    id = round(bat*10)/10;
    
    % Check if snap with same battery level exists
    exists = 0;
    
    for i = 1:length(snaps)
        if (snaps{i}.id == id) || (isnan(id) && isnan(snaps{i}.id))
            exists = i;
        end
    end
    
    new_snap.id = id;
    new_snap.bat = bat;
    new_snap.FOC = FOC;
    new_snap.TOC = TOC;
    new_snap.bound = bound;
    new_snap.weight = weight;
    new_snap.poles = poles;
    new_snap.res = res;
    
    if ~exists
        display '[SNAPSHOT] New snapshot added!';
        snaps{length(snaps)+1} = new_snap;
    else
        display(['[SNAPSHOT] Snapshot at level ' num2str(id) ' overwritten!']);
        snaps{exists} = new_snap;
    end
    
    status_update('Snapshot saved');
end