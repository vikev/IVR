function bwBall(file_dir,learnSize)
filenames = dir([file_dir '*.jpg']);

frame = imread([file_dir filenames(1).name]);
figure(2);
h1 = imshow(frame);
[x,y,rS]=size(frame);
gray=rgb2gray(frame);
M=gray;
Min=gray;
Max=gray;
oldPerim = zeros(x,y);

%how many frames back should compare
back=2;
prevFrames(:,:,back)=gray;
updates=0;
% currently adds everything into one array
path = [];

% Read one frame at a time.
for k = 2 : size(filenames, 1)
    frame = imread([file_dir filenames(k).name]);
    gray=rgb2gray(frame);
    Bim = zeros(x,y);
    
    diff=abs(gray-prevFrames(:,:,back));
    diff(diff<5)=0;
    diff(diff>0)=1;
    diff=bwmorph(diff, 'erode', 1);
    for i = back : 2
        prevFrames(:,:,i)=prevFrames(:,:,i-1);
    end
    prevFrames(:,:,1)=gray;
    
    %if k<=learnSize
    if diff==zeros(x,y)
        updates=updates+1;
        M=M+gray;
        Min=min(Min,gray);
        Max=max(Max,gray);
    end
    
  %  if k==learnSize
    %    M=M./updates;
   % end
    
    if k>learnSize
        for i=1:x,
            for j=1:y
                if gray(i,j) < Min(i,j)-5 || gray(i,j)>Max(i,j)+5
                    Bim(i,j)=1;
                end
            end
        end
        
    end
    
    
    Bim = bwmorph(Bim, 'erode', 2);
    [frame,oldPerim] = drawPerim(frame,Bim,oldPerim);
    
    % Show frame
    imshow(frame);
    %subplot(1, 2, 1, 'align'), imshow(Bim, 'InitialMagnification', 100, 'Border','tight');
    %subplot(1, 2, 2, 'align'), imshow(frame, 'InitialMagnification', 100, 'Border','tight');
    %truesize
    
    % Draw object's centres on the frame
    centres = drawCentres(Bim);
    
    % Extend path array
    % TODO only works if one object on the frame
    if ~isempty(centres)
        path = [path ; [centres(1, 1) centres(1,2)]];
        %if length(path) > 3
        %    dis = distance(path(end-1, 1), centres(1,1), path(end-1, 2), centres(1,2));
        %    if dis > 10
        %        dis
        %    end
        %end
    end
    
    % Draw path of the object on the frame
    drawPath(path);
    
    % Draw highest point if the object is on it's highest point
    %[p1, p2] = size(path);
    %if p1 > 2
    %    drawHighest(path, Bim);
    %end
    
    %h2 = rectangle('position',[ 150 40 80 70]);
    %set(h2,'EdgeColor','w','LineWidth',2)
    drawnow('expose');
    %disp(['showing frame ' num2str(k)]);
end