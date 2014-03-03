function s = getObjects(binaryImage)
     
     % Clean binary image
     binaryImage = bwmorph(binaryImage, 'clean');
     
     % Label objects in binary image
     labeled = bwlabel(binaryImage, 4);
     
     % Get the centres of labeled object
     s  = regionprops(labeled, 'centroid', 'perimeter', 'area', 'boundingbox', 'eccentricity');
     