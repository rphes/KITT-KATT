function butPFilter_callback(src, e)
    global use_pfilter;
    
    if use_pfilter
        set(src,'String','PRED FILTER OFF <P>');
        use_pfilter = 0;
        status_update('Prediction filter off');
    else
        set(src,'String','PRED FILTER ON <P>');
        use_pfilter = 1;
        status_update('Prediction filter on');
    end
end