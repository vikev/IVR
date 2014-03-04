function is = isHighest(path)
% Knowing a path so far check if that's the highest point of the path

is = false;

% Find the point where the ball stops moving up
% by finding sin(angle) between ball moving
% direction and y = 0
if path(end-1, 2) < path(end, 2)
    v1 = path(end-1, 2) - path(end, 2);
    sin_alpha = v1/distance(path(end-1, 1), path(end, 1), path(end-1, 2), path(end, 2));
    
    % If sine is less than or equal to 0 -> ball no longer
    % moves up
    % Also check if the ball is not moving down to fast to be at
    % the highest point
    if sin_alpha <= 0 && v1 >= -1
        is = true;
    end
end