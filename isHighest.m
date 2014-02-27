function is = isHighest(path)
    
     % Knowing a path so far check if that's the highest point of the path
     
     % Currently just checking if the current and previous distance per 
     % frame is less than 1 
     
     is = false;
     
     dCur = distance(path(end, 1), path(end-1, 1), path(end, 2), path(end-1, 2));
     
     dPre = distance(path(end-1, 1), path(end-2, 1), path(end-1, 2), path(end-2, 2));
     
     if dCur <= 1 && dPre <= 1
        is = true;
     end
     