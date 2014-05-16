function [stylo] = plotstyle (type)
    if type == 'line'
        stylo = ''LineWidth'',2,''r'';
    end
    if type == 'dot'
        stylo = ['MarkerSize',15];
    end
end