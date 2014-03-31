function sRes_value_callback(src, e)
    global sRes;
    global labRes;
    set(labRes.text,'String',['Resistance: ' num2str(round(get(sRes, 'Value')*1000)/1000)]);
    
    calculate_model();
end