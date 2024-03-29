function drawPath(path, color) 
     % Draw the path by drawing lines between two lines in path array  
     
     n = length(path);
     if n > 2
        hold on; 
        for i = 1 : n-1
            line([path(i, 1), path(i+1, 1)],[path(i, 2), path(i+1, 2)],'Color',color,'LineWidth',1);
        end
        hold off;
     end
     