function [ret] = KITT_status(status)
    splitted = strsplit(status, char(10));
    
    % Get distances
    distances = splitted{2};
    distances = distances(2:length(distances));
    distances = strsplit(distances, ' ');
    ret.distanceLeft = str2num(distances{1})/100;
    ret.distanceRight = str2num(distances{2})/100;
    
    if ret.distanceLeft == 9.99
        ret.distanceLeft = 3;
    end
    
    if ret.distanceRight == 999
        ret.distanceRight = 3;
    end
    
    % Get battery voltage
    batt = splitted{3};
    batt = batt(2:length(batt));
    ret.batteryVoltage = str2num(batt)/1000;
    
    % Get audio enabled
    ret.audioEnabled = str2num(splitted{4}(7));
end