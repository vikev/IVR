function is = isBall(P, A)
is = false;
if P>20 && A>100
    comp = 2 * sqrt(A*pi)/P;
    roundness =  4*pi*A/P^2;
    if (comp > 0.90 && roundness >0.80) || (comp > 0.80 && roundness >0.90) 
        is = true;
    end    
end