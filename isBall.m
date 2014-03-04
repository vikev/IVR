function is = isBall(P, A, E, MIN_AREA)
    % Determine if the object is ball or not
    % given the perimeter P,
    % area A and eccentricity E of the object
    
    MIN_COMP = 0.94;
    MAX_ECC = 0.75;
    MIN_SUM = 1.6;
    MAX_SUM = 1.7;
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
    % 0.948 no more
    if comp > MIN_COMP && A > MIN_AREA && E < MAX_ECC && MIN_SUM <= sum && sum <= MAX_SUM
        is = true;
    end
