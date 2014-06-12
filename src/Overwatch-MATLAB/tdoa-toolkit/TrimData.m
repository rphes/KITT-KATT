function [DataTrimmed] = TrimData(Data, Fs, PeakThreshold, PeakFrequency, SkipCoefficient, ClearanceAfter, ClearanceBefore)
    % Determine which signal to use
    Quality = max(Data)./std(Data); % Assume constant noise
    [~, BestChannel] = max(Quality);
    Reference = Data(:,BestChannel);

    % Determine peaks
    IntervalLength = round(Fs/PeakFrequency);
    Index = 1;
    MaxValue = max(Reference);
    Peaks = [];

    while Index < length(Reference)
        if Reference(Index) >= PeakThreshold*MaxValue
            % Save peak if conditions are met
            if (Index > ClearanceBefore) && (Index < length(Reference)-ClearanceAfter)
                Peaks = [Peaks Index];
            end

            % Skip
            Index = Index + IntervalLength*SkipCoefficient;
        end

        Index = Index + 1;
    end
    
    % Check if a valid peak is found
    if length(Peaks) == 0
        DataTrimmed = [];
        return
    end

    % Determine interval
    Peak = Peaks(length(Peaks)); % Use final peak for most up-to-date data
    DataTrimmed = Data((Peak-ClearanceBefore):(Peak+ClearanceAfter),:);
end