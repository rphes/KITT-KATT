function sRef_value_callback(src, e)
    global sRef;
    global labRef;
    set(labRef.text,'String',['Reference: ' num2str(round(get(sRef, 'Value')*100)/100) 'm']);
end