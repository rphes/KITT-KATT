function sPoles_value_callback(src, e)
    global sPoles;
    global labPoles;
    set(labPoles.text,'String',['Poles: ' num2str(round(get(sPoles, 'Value')*100)/100)]);
    
    calculate_model();
end