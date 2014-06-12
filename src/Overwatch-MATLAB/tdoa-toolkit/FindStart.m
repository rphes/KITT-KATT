function [Start] = FindStart(Data, Threshold)
    MaxLevel = max(Data);
    
    for Start = 1:length(Data)
        if Data(Start) >= MaxLevel*Threshold
            break
        end
    end
end