function reset_axes(aHandle)
    set(aHandle,...
        'XLim',[0 Cfg.PlotTimeFrame],...
        'XTick', 0:1:Cfg.PlotTimeFrame ...
        );
end