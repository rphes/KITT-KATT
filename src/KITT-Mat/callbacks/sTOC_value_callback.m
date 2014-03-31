function sTOC_value_callback(src, e)
    global sTOC;
    global labTOC;
    set(labTOC.text,'String',['Mapping t.o.c.: ' num2str(round(get(sTOC, 'Value')*10000)/10000)]);
end