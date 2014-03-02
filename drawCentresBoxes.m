function ball_cen = drawCentresBoxes(binaryImage)
     
     % Clean binary image
     binaryImage = bwmorph(binaryImage, 'clean');
     
     % Label objects in binary image
     labeled = bwlabel(binaryImage, 4);
     
     % Get the centres of labeled object
     s  = regionprops(labeled, 'centroid', 'perimeter', 'area', 'boundingbox');
     cen = cat(1, s.Centroid);
     
     % Find the number of object in the image and draw
     % each of their centres on the frame
     nrCentres = length(s);
     ball_cen = [];
     hold on;
     for i = 1 : nrCentres
        if isBall(s(i).Perimeter, s(i).Area)
            ball_cen = [ball_cen ; cen(i, :)];
            thisBB = s(i).BoundingBox;
            rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)], 'EdgeColor','b','LineWidth', 1);
            plot(int32(cen(i,1)),int32(cen(i, 2)),'o');
        end
     end
     hold off;
     
     