function bwBall(file_dir,learnSize)
filenames = dir([file_dir '*.jpg']);

frame = imread([file_dir filenames(1).name]);
figure(2); 
h1 = imshow(frame);
[x,y,rS]=size(frame);

M=zeros(x,y);
Min=ones(x,y)*10000;
Max=zeros(x,y);
oldPerim = zeros(x,y);

%currently only one path
path = []; 

% Read one frame at a time.
for k = 1 : size(filenames, 1)
    frame = imread([file_dir filenames(k).name]);
    Bim = zeros(x,y);
    frame2 = myrgb2gray(frame);
    
    if k<=learnSize
      for i=1:x,
        for j=1:y
            M(i,j)=M(i,j)+frame2(i,j);
            if(Min(i,j)>frame2(i,j))
                Min(i,j)=frame2(i,j);
            end
            if(Max(i,j)<frame2(i,j))
                Max(i,j)=frame2(i,j);
            end
        end
      end
    end
    
    if k==learnSize
        M=M./learnSize;
    end
    
    if k>learnSize
        for i=1:x,
        for j=1:y
            if frame2(i,j)<Min(i,j)-5 || frame2(i,j)>Max(i,j)+5
                Bim(i,j)=1;
            end
        end
        end
      
    end
    
    
    Bim = bwmorph(Bim, 'erode', 2);    
    [frame,oldPerim] = drawPerim(frame,Bim,oldPerim);
    
    % Show frame
    imshow(frame);
    
    % Draw object's centres on the frame
    centres = drawCentres(Bim);
    
    % Extend path array
    if length(centres) ~= 0
        path = [path ; [centres(1, 1) centres(1,2)]];
    end
    
    % Draw paths of the objects on the frame
    drawPath(path);
    %h2 = rectangle('position',[ 150 40 80 70]);
    %set(h2,'EdgeColor','w','LineWidth',2)
    drawnow('expose');
    %disp(['showing frame ' num2str(k)]);
end