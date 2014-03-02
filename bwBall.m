function bwBall(file_dir,learnSize,back)
filenames = dir([file_dir '*.jpg']);

frame = imread([file_dir filenames(1).name]);
figure(1);

x=size(frame,1);
y=size(frame,2);
gray=rgb2gray(frame);
M=gray;
Min=gray;
Max=gray;
oldPerim = zeros(x,y);


% structure where we keep our detected objects
objects=struct('path',{},'lastSeen',{});

%how many frames back should compare
%back=2;
prevFrames(:,:,back)=gray;
updates=0;

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
    
    if diff==zeros(x,y)
        updates=updates+1;
        M=M+gray;
        Min=min(Min,gray);
        Max=max(Max,gray);
    end
    
    
    if k>learnSize
        Bim(gray<Min-5)=1;
        Bim(gray>Max+5)=1;
    end
    
    
    Bim = bwmorph(Bim, 'erode', 2);
    
    % Show frame
    imshow(frame);
    %subplot(1, 2, 1, 'align'), imshow(Bim, 'InitialMagnification', 100, 'Border','tight');
    %subplot(1, 2, 2, 'align'), imshow(frame, 'InitialMagnification', 100, 'Border','tight');
    %truesize
    
    % Draw object's centres on the frame
    centres = drawCentresBoxes(Bim);
    
    updateObjects();
    removeLostObjects();
    drawPaths();
    
    drawnow('expose');
    
end

    function updateObjects()
        for i=1 : size(centres,1)
            assigned = false;
            
            for j=1 : size(objects,2)
                if(objects(j).lastSeen<k)
                    x1=objects(j).path(end,1);
                    y1=objects(j).path(end,2);
                    x2=centres(i,1);
                    y2=centres(i,2);
                    dist=distance(x1,x2,y1,y2);
                    disp(dist);
                    if(dist<15)
                        objects(j).path=[ objects(j).path ; [centres(i, 1) centres(i,2)]];
                        objects(j).lastSeen=k;
                        assigned=true;
                    end
                end
            end
            if ~assigned
                objects(end+1)=struct('path',[[centres(i, 1) centres(i,2)]],'lastSeen',k);
            end
        end
        %disp(objects);
    end

    function removeLostObjects()
        rm=[];
        for i=1 : size(objects,2)
            if(objects(i).lastSeen<k-10)
                rm=[rm i];
            end
        end
        objects(rm)=[];
    end

    function drawPaths()
        for i=1 : size(objects,2)
            % Draw highest point if the object is on it's highest point
            path=objects(i).path;
            drawPath(path);
            %[p1, p2] = size(path);
            %if p1 > 2
            %    drawHighest(path, Bim);
            %end
        end
    end

end