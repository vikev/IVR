function highest = drawHighest(path)
    % Recognizes whether the ball is at his highest point,
    % draws the cross
    
    highest = 0;
     
    hold on;
    if isHighest(path)
        plot(int32(path(end, 1)),int32(path(end, 2)), 'xr', 'MarkerSize',20);
        highest = 1;
    end
    hold off;
     