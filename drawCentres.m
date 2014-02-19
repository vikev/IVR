function [originalImage, cen] = drawCentres(originalImage, binaryImage)
     
     binaryImage = bwmorph(binaryImage, 'clean');
     labeled = bwlabel(binaryImage, 4);
     
     s  = regionprops(labeled, 'centroid');
     cen = cat(1, s.Centroid);
     
     
     nrCentres = length(s);
     for i = 1 : nrCentres
            t = int32(cen(i, 1));
            o = int32(cen(i, 2));
            originalImage(o, t, 1) = 255;
            originalImage(o, t, 2) = 0;
            originalImage(o, t, 3) = 0;
            %hold on
            %line([0,100],[100,0],'Color',[1 0 0],'LineWidth',2)
     end
     
     