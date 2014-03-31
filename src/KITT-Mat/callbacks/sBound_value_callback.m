function sBound_value_callback(src, e)
    global sBound;
    global labBound;
    set(labBound.text,'String',['Mapping bound: ' num2str(round(get(sBound, 'Value')*10000)/10000)]);
end