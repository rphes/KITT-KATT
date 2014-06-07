function shiftAxis(axisHandle, curTime)
    if curTime > Configuration.PlotTimeFrame
        % Find nearest multiple of Configuration.PlotTimeFrame/2 above curTime
        frameTime = ceil(curTime/(Configuration.PlotTimeFrame/2))*(Configuration.PlotTimeFrame/2);

        set(axisHandle,...
            'XLim',[frameTime-Configuration.PlotTimeFrame frameTime],...
            'XTick',frameTime-Configuration.PlotTimeFrame:5:frameTime...
            );
    end
end