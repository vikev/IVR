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
objects=struct('path',{},'lastSeen',{},'colour',{});
if(back>0)
    prevFrames(:,:,back)=gray;
end
updates=0;

% Read one frame at a time.
for k = 2 : size(filenames, 1)
    frame = imread([file_dir filenames(k).name]);
    
    normalised = bsxfun(@rdivide, im2double(frame), sum(im2double(frame),3,'native'));
    
    imshow(frame);
    gray=rgb2gray(frame);
    Bim = zeros(x,y);
    if back>0
        diff=abs(gray-prevFrames(:,:,back));
        diff(diff<5)=0;
        diff(diff>0)=1;
        diff=bwmorph(diff, 'erode', 1);
        for i = back : 2
            prevFrames(:,:,i)=prevFrames(:,:,i-1);
        end
        prevFrames(:,:,1)=gray;
    end
    if k<learnSize || (back>0 && diff==zeros(x,y))
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
    %imshow(frame);
    %subplot(1, 2, 1, 'align'), imshow(Bim, 'InitialMagnification', 100, 'Border','tight');
    %subplot(1, 2, 2, 'align'), imshow(frame, 'InitialMagnification', 100, 'Border','tight');
    %truesize
    
    % Draw object's centres on the frame
    centres = drawCentresBoxes(Bim);
    
    updateObjects();
    removeLostObjects();
    drawPaths();

    
    %h2 = rectangle('position',[ 150 40 80 70]);
    %set(h2,'EdgeColor','w','LineWidth',2)

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
                    
                    currCentreColour=normalised(uint8(centres(i, 1)),uint8(centres(i,2)),:);
                    if(dist<15&&isCloseRGBVal(objects(j).colour,currCentreColour))
                        objects(j).path=[ objects(j).path ; [centres(i, 1) centres(i,2)]];
                        objects(j).lastSeen=k;
                        objects(j).colour=currCentreColour;
                        assigned=true;
                    end
                end
            end
            if ~assigned
                objects(end+1)=struct('path',[[centres(i, 1) centres(i,2)]],'lastSeen',k,'colour',normalised(uint8(centres(i, 1)),uint8(centres(i,2)),:));
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

    function is = isCloseRGBVal(pixel1, pixel2)
        is=true;
        thresh=10;
        if(abs(pixel1(1,1,1)-pixel2(1,1,1))>thresh)
            is=false;
        end
        if(abs(pixel1(1,1,2)-pixel2(1,1,2))>thresh)
            is=false;
        end
        if(abs(pixel1(1,1,3)-pixel2(1,1,3))>thresh)
            is=false;
        end
    end

end