function is = isBall(P, A, E)
     
     is = false;
     comp = 2 * sqrt(A*pi)/P;
     S = comp + E;
     if comp > 0.95 && A > 50 && E < 0.75 && 1.6 <= S && S <= 1.7
         is = true;
     end