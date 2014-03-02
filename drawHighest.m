function highest = drawHighest(path)

     highest = 0;
     
     hold on;
     if isHighest(path)
         plot(int32(path(end, 1)),int32(path(end, 2)), 'xr', 'MarkerSize',20);
         pause(3);
         highest = 1;
     end
     hold off;
     