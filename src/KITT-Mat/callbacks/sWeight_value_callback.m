function sWeight_value_callback(src, e)
    global sWeight;
    global labWeight;
    set(labWeight.text,'String',['Weight: ' num2str(round(get(sWeight, 'Value')*100)/100) 'kg']);
    
    calculate_model();
end