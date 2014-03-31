function add_line_point(lHandle, x, y)
    curX = get(lHandle, 'XData');
    curY = get(lHandle, 'YData');
    curX(length(curX)+1) = x;
    curY(length(curY)+1) = y;
    set(lHandle, 'XData', curX);
    set(lHandle, 'YData', curY);
end