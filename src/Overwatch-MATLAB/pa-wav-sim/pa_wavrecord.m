function y = pa_wavrecord(FirstChannel, LastChannel, NumberSamples, Fs)
    % Assertions
    assert(FirstChannel == 1);
    assert(LastChannel == 5);
    assert(Fs == 48000);
    
    % Get random piece of data
    global paWavSimTic
    global RecordData
    Data = RecordData{10};    
    SampleDelay = round(Fs*toc(paWavSimTic));
    
    IntervalBegin = SampleDelay;
    IntervalEnd = IntervalBegin + NumberSamples;
    
    if IntervalEnd > length(Data)
        IntervalEnd = length(Data);
        IntervalBegin = IntervalEnd - NumberSamples;
    end
    
    y = Data(IntervalBegin:IntervalEnd, :);
    
    % Sleep (+ processing time) to make it realistic
    pause(NumberSamples/Fs*(1 + 0.2 + 0.05*rand()));
end