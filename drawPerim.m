function [image, perim] = drawPerim(originalImage, binaryImage, oldPerim)
     perim = bwperim(binaryImage);
     [m,n,rS]=size(perim);
     for i=1 : m
     for j =1 : n
        perim(i,j)=max(perim(i,j)-oldPerim(i,j),0);
     end
     end
     
     
     image=originalImage;
     image(perim)=255;