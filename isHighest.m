function is = isHighest(path)
    
     % Knowing a path so far check if that's the highest point of the path
     
     is = false;
     
     dCur = distance(path(end, 1), path(end-1, 1), path(end, 2), path(end-1, 2));
     
     v1 = path(end-1, 2) - path(end, 2);
     sin_alpha = v1/distance(path(end-1, 1), path(end, 1), path(end-1, 2), path(end, 2));
     
     if sin_alpha < 0 % || abs(path(end, 2) - path(end-1, 2)) <= 0.15 || dCur < 1
        is = true;
     end
     