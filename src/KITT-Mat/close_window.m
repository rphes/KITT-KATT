function close_window(src, e, opt)
    global running;
    global snaps;
    global fig;
    running = 0;
    
    set(fig,'Visible','off');
    
    display '[SNAPSHOT] Saving snapshots';
    save('snaps.mat','snaps');
    
    display '[SYSTEM] Awaiting loop';
end