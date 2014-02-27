function trackBalls(file_dir,learnSize)

filenames = dir([file_dir '*.jpg']);

frame = imread([file_dir filenames(1).name]);
figure(2);

x=size(frame,1);
y=size(frame,2);
Min=ones(x,y)*10000;
Max=zeros(x,y);
mean = rgb2gray(frame);
var=ones(x,y);
p=0.05;
m=1.5;
imshow(frame);
drawnow('expose');

for k = 2 : size(filenames, 1)
    frame = imread([file_dir filenames(k).name]);
    % Show frame
    gray = rgb2gray(frame);
    bim = zeros(x,y);
    if(k<=learnSize)
        mean=mean+gray;
        for i=1:x,
            for j=1:y
                if(Min(i,j)>gray(i,j))
                    Min(i,j)=gray(i,j);
                end
                if(Max(i,j)<gray(i,j))
                    Max(i,j)=gray(i,j);
                end
            end
        end
    end
    if(k==learnSize)
        mean=mean/learnSize;
        var = double(abs(Min-Max)/2);
        var=var.^2;
    end
    if(k>learnSize)
        mean=p*gray+(1-p)*mean;
        d=double(abs(mean-gray));
        var = p*(d.^2)+(1-p)*var;
        
        for i=1:x
            for j=1:y
                if (abs(gray(i,j)-mean(i,j))/30)>m
                    bim(i,j)=1;
                end
            end
        end
    end
    imshow(bim);
    drawnow('expose');
    
end

end