function drawHighest(path, binaryImage)

     % TODO only works with one object on the frame

     % Clean binary image
     binaryImage = bwmorph(binaryImage, 'clean');
     
     % Label objects in binary image
     labeled = bwlabel(binaryImage, 4);
     
     % Get the centres of labeled object
     s  = regionprops(labeled, 'boundingbox');
     
     % For every object draw the boundaries for this object
     % and if this object is at his highest point - return it
     % TODO currently works only for one object
     hold on;
     m = 0;
     if length(s) > 0
         m = 1;
     end
     for k = 1 : m %length(s)
        if isHighest(path)
            plot(int32(path(end, 1)),int32(path(end, 2)), 'xr', 'MarkerSize',20);
            pause(3);
        end
     end
     hold off;
     