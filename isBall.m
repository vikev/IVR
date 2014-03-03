function is = isBall(P, A)
is = false;
if P>20 && A>100
    comp = 2 * sqrt(A*pi)/P;
    if comp > 0.80 
        is = true;
    end    
end