function bwBall(file_dir,learnSize,back)
filenames = dir([file_dir '*.jpg']);

frame = imread([file_dir filenames(1).name]);
figure(1);

x=size(frame,1);
y=size(frame,2);
gray=rgb2gray(frame);
M=uint8(zeros(x,y));
Min=gray;
Max=gray;



% structure where we keep our detected objects
objects=struct('path',{},'lastSeen',{},'colour',{}, 'highest', 0, 'box', {});
if(back>0)
    prevFrames(:,:,back)=gray;
end
updates=0;

% Read one frame at a time.
for k = 1 : size(filenames, 1)
    frame = imread([file_dir filenames(k).name]);
    
    normalised = bsxfun(@rdivide, im2double(frame), sum(im2double(frame),3,'native'));
    
    gray=rgb2gray(frame);
    Bim = zeros(x,y);
    
    noforeground=false;
    if back>1
        diff=abs(gray-prevFrames(:,:,back));
        diff(diff<5)=0;
        diff(diff>0)=1;
        diff=bwmorph(diff, 'erode', 1);
        for i = back : 2
            prevFrames(:,:,i)=prevFrames(:,:,i-1);
        end
        prevFrames(:,:,1)=gray;
        if diff==zeros(x,y)
            noforeground = true;
        end
    end
    if k<=learnSize || (back>1 && noforeground)
        updates=updates+1;
        M=M+gray;
        Min=min(Min,gray);
        Max=max(Max,gray);
    end
    
    
    if k>learnSize
        Bim(gray<Min-5)=1;
        Bim(gray>Max+5)=1;
    end
    
    Bim = bwmorph(Bim, 'close', Inf);
    Bim = medfilt2(Bim);

    % Show frame
    imshow(frame);
    %maskBim = Bim*255;
    %maskBim = cat(3, maskBim, maskBim, maskBim);
    %maskNorm = normalised*255;
    %top = cat(2, frame, maskBim);
    %bottom = cat(2, frame, maskNorm);
    %imshow(cat(1, top, bottom));
    %imshow(top);
    
    % Get moving objects in the frame
    objProp = getObjects(Bim);
    % Update object struct with a new found objects proporties
    updateObjects();
    % Remove objects that haven't moved recently
    removeLostObjects();
    % Draw objects (hopefully balls) in the current state
    drawInfo();
    
    drawnow('expose');
    
end

    function updateObjects()
        
        centres = cat(1, objProp.Centroid);
        
        for i = 1 : size(centres,1)
            assigned = false;
            
            for j = 1 : size(objects, 2)
                if(objects(j).lastSeen<k)
                    x1=objects(j).path(end,1);
                    y1=objects(j).path(end,2);
                    x2=centres(i,1);
                    y2=centres(i,2);
                    dist=distance(x1,x2,y1,y2);
                    currCentreColour=normalised(uint8(centres(i, 1)),uint8(centres(i,2)),:);
                    if(dist<15&&isCloseRGBVal(objects(j).colour,currCentreColour,3))
                        objects(j).path=[ objects(j).path ; [centres(i, 1) centres(i,2)]];
                        objects(j).lastSeen=k;
                        objects(j).colour=currCentreColour;
                        objects(j).box = objProp(i).BoundingBox;
                        assigned=true;
                    end
                end
            end
            if ~assigned && isBall(objProp(i).Perimeter, objProp(i).Area, objProp(i).Eccentricity)
                objects(end+1)=struct('path',[[centres(i, 1) centres(i,2)]],'lastSeen',k,'colour',normalised(uint8(centres(i, 1)),uint8(centres(i,2)),:), 'highest', 0, 'box', objProp(i).BoundingBox);
            end
        end
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

    function drawInfo()
        needPause = 0;
        for i = 1 : size(objects, 2)
            % Draw ball's centre
            drawCentres(objects(i).path(end, :));
            % Draw bounding box
            drawBox(objects(i).box);
            % Draw path
            path = objects(i).path;
            drawPath(path);
            % Draw highest point
            [p1, p2] = size(path);
            if p1 > 2 && ~objects(i).highest
                if drawHighest(path)
                    objects(i).highest = 1;
                    needPause = 1;
                end
            end
        end
        if needPause == 1
            pause(3);
        end
    end

    function is = isCloseRGBVal(pixel1, pixel2,thresh)
        is=true;
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