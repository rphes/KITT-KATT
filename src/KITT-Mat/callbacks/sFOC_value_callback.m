function sFOC_value_callback(src, e)
    global sFOC;
    global labFOC;
    set(labFOC.text,'String',['Mapping f.o.c.: ' num2str(round(get(sFOC, 'Value')*100)/100)]);
end