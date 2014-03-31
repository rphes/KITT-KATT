function butSensor_callback(src, e)
    global sensor_mode
    
    if sensor_mode == SensorMode.LEFT
        set(src,'String', 'RIGHT SENSOR <S>');
        sensor_mode = SensorMode.RIGHT;
        status_update('Using right sensor');
    elseif sensor_mode == SensorMode.RIGHT
        set(src,'String', 'HIGH SENSOR <S>');
        sensor_mode = SensorMode.HIGH;
        status_update('Using highest sensor');
    else
        set(src,'String', 'LEFT SENSOR <S>');
        sensor_mode = SensorMode.LEFT;
        status_update('Using left sensor');
    end
end