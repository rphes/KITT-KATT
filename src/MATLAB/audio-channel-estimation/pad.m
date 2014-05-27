function [seq] = pad(seq, len)
    diff = length(seq)-len;

    if diff < 0
        seq = [seq zeros(1,-diff)];
    elseif diff > 0
        seq = seq(1:len);
    end
end