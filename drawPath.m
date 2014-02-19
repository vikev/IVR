function drawPath(path) 
     
     n = length(path);
     if n > 2
        path
        for i = 1 : n-1
            line([path(i, 1), path(i+1, 1)],[path(i, 2), path(i+1, 2)],'Color',[1 0 0],'LineWidth',2);
        end
     end