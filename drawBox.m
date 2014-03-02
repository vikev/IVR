function drawBox(box)
     hold on;
     rectangle('Position', [box(1),box(2),box(3),box(4)], 'EdgeColor','b','LineWidth', 1);
     hold off;
     