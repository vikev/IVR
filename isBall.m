function is = isBall(P, A)
     
     is = false;
     comp = 2 * sqrt(A*pi)/P;
     if comp > 0.95 && A > 50
         is = true;
     end
     
     