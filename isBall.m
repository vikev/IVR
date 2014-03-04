function is = isBall(P, A, E, CI)
    % Determine if the object is ball or not
    % given the perimeter P,
    % area A and eccentricity E of the object
    is = false;
    
    % Calculate the compactness of the object
    comp = 2 * sqrt(A*pi)/P;

    % Calculate the sum of compactness and eccentricity
    sum = comp + E;
    
    % The object is ball if all of the following are true:
    %  - Object's area is larger than 50 (avoiding noise)
    %  - Compactness is nearly 1 since we are looking for 
    %    a ball (ball is indeed similar to circle
    %  - Eccentricity is less than 0.75
    %  - The sum of compactness and eccentricity is between
    %    1.6 and 1.7 (found by performing a lot of tests)
    if A >50 && E < 0.75 && comp > 0.947
        %comp
        %E
        %sum
    end
    % 0.948 no more
    if comp > 0.947 && A > 50 && E < 0.75 && 1.6 <= sum && sum <= 1.7
        is = true;
        %M = moment(CI, 2)
    end
