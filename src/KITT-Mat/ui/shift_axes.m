function shift_axes(aHandle, cur_time)
    if cur_time > Cfg.PlotTimeFrame
        % Find nearest multiple of Cfg.PlotTimeFrame/2 above cur_time
        frame_time = ceil(cur_time/(Cfg.PlotTimeFrame/2))*(Cfg.PlotTimeFrame/2);

        set(aHandle,...
            'XLim',[frame_time-Cfg.PlotTimeFrame frame_time],...
            'XTick',frame_time-Cfg.PlotTimeFrame:1:frame_time...
            );
    end
end