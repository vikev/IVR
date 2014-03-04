function drawBox(box, color)
    % Draw the bounding box
    hold on;
    rectangle('Position', [box(1),box(2),box(3),box(4)], 'EdgeColor', color,'LineWidth', 1);
    hold off;
     