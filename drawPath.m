function drawPath(path) 
     % Draw the path by drawing lines between two lines in path array  
     
     n = length(path);
     if n > 2
        for i = 1 : n-1
            line([path(i, 1), path(i+1, 1)],[path(i, 2), path(i+1, 2)],'Color',[1 0 0],'LineWidth',1);
        end
     end
     