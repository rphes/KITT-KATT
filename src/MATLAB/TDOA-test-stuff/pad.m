function [seq] = pad(seq, len)
    diff = length(seq)-len;

    if diff < 0
        seq = [seq; zeros(-diff,1)];
    elseif diff > 0
        seq = seq(1:len);
    end
end