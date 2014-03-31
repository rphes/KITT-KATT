function butLPFilter_callback(src, e)
    global use_lpfilter;
    
    if use_lpfilter
        set(src,'String','LP FILTER OFF <L>');
        use_lpfilter = 0;
        status_update('Low-pass filter off');
    else
        set(src,'String','LP FILTER ON <L>');
        use_lpfilter = 1;
        status_update('Low-pass filter on');
    end
end