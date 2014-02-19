function [image, perim] = drawPerim(originalImage, binaryImage, oldPerim)
     perim = bwperim(binaryImage);
     [m,n,rS]=size(perim);
     for i=1 : m
     for j =1 : n
        perim(i,j)=max(perim(i,j)-oldPerim(i,j),0);
     end
     end
     
     
     
     imshow(perim);
     
     image=originalImage;
     image(perim)=255;
     
     %I2 = originalImage; I2(perim) = 255;
     %image = I2;
     %I2 = originalImage; I2(perim) = 0;
     %image(:,:,2) = I2;
     %I2 = originalImage; I2(perim) = 0;
     %image(:,:,3) = I2;