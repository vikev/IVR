function cen = drawCentres(binaryImage)
     
     % Clean binary image
     binaryImage = bwmorph(binaryImage, 'clean');
     
     % Label objects in binary image
     labeled = bwlabel(binaryImage, 4);
     
     % Get the centres of labeled object
     s  = regionprops(labeled, 'centroid');
     cen = cat(1, s.Centroid);
     
     % Find the number of object in the image and draw
     % each of their centres on the frame
     nrCentres = length(s);
     hold on;
     for i = 1 : nrCentres
        plot(int32(cen(i,1)),int32(cen(i, 2)),'o');
     end
     hold off;
     
     