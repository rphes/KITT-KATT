function addLinePoint(lineHandle, x, y)
    curX = get(lineHandle, 'XData');
    curY = get(lineHandle, 'YData');
    curX(length(curX)+1) = x;
    curY(length(curY)+1) = y;
    set(lineHandle, 'XData', curX);
    set(lineHandle, 'YData', curY);
end