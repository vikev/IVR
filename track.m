function track(FILE_DIR,LEARN_SIZE,MIN_AREA,LOOK_BACK,VIEW)

BALL_FOR_SURE = 5;

if MIN_AREA < 50
    MIN_AREA = 50;
end

filenames = dir([FILE_DIR '*.jpg']);

frame = imread([FILE_DIR filenames(1).name]);
figure(1);

y = size(frame, 1);
x = size(frame, 2);

objects = struct('path', {}, 'lastSeen', {}, 'colour', {}, 'highest', 0, 'box', {}, 'isBall', {}, 'ballCount', 0);

backgroundSum = double(zeros(y, x, 3));
foreground = zeros(y, x);
diff = zeros(y, x);
updated = 0;
frameD = double(frame);

frameBuff(:, :, :, 1) = frameD;
if LOOK_BACK > 0
    frameBuff(:, :, :, LOOK_BACK) = frameD;
end

% play 'video'
for k = 1 : size(filenames, 1)
    frame = imread([FILE_DIR filenames(k).name]);
    frameD = double(frame);
    if k <= LEARN_SIZE
        updated = updated + 1;
        backgroundSum = frameD + backgroundSum;
    end
    if k == LEARN_SIZE
        background = backgroundSum/LEARN_SIZE;
    end
    % show frame
    if VIEW == 0
        imshow(frame);
    else
        d=diff*255;
        
        f=foreground*255;
        bwims = cat(2, cat(3,f,f,f), cat(3,d,d,d));
        imshow(cat(2,frame,bwims));
    end
    if k>LEARN_SIZE
        props = extractForegroundObjects();
        centres = cat(1, props.Centroid);
        updateObjectsStruct();
        removeLostObjects();
        drawInfo();
        
    end
    
    if k > LEARN_SIZE && LOOK_BACK > 0
        diff=zeros(y, x);
        diff(abs(frameD(:, :, 1) - frameBuff(:, :, 1, LOOK_BACK)) > 5) = 1;
        diff(abs(frameD(:, :, 2) - frameBuff(:, :, 2, LOOK_BACK)) > 5) = 1;
        diff(abs(frameD(:, :, 3) - frameBuff(:, :, 3, LOOK_BACK)) > 5) = 1;
        diff = bwmorph(diff, 'erode', 2);
        
        if diff == zeros(y,x)
            background = (background + 2*frameD)/3;
            updated = updated + 1;
            
        end
    end
    
    if LOOK_BACK > 0
        updateFrameBuffer();
    end
    %imShow(frame);
    
    
    drawnow('expose');
end

% this function compares the current frame to the estimated backgroung value and returns the finds foreground objects
    function props = extractForegroundObjects()
        foreground = zeros(y,x);
        foreground(abs(frameD(:, :, 1) - background(:, :, 1)) > 8) = 1;
        foreground(abs(frameD(:, :, 2) - background(:, :, 2)) > 8) = 1;
        foreground(abs(frameD(:, :, 3) - background(:, :, 3)) > 8) = 1;
        
        % Filters
        foreground = bwmorph(foreground, 'erode', 1);
        foreground = bwmorph(foreground, 'close', Inf);
        foreground = medfilt2(foreground);
        
        % Get information about the objects
        labels = bwlabel(foreground, 4);
        props = regionprops(labels, 'centroid', 'perimeter', 'area', 'boundingbox', 'eccentricity', 'conveximage', 'MajorAxisLength', 'MinorAxisLength');
        
        % Remove small objects (noise)
        rm = [];
        for i = 1 : length(props)
            if props(i).Area < MIN_AREA
                rm = [rm i];
            end
        end
        props(rm) = [];
    end

% dispaly paths, centroids and centers for every object in objects struct
    function drawInfo()
        needPause = 0;
        for i = 1 : size(objects, 2)
            % Draw ball's centre
            %drawCentres(objects(i).path(end, :));
            % Draw blue bounding box if the object is a ball
            % red box - otherwise and path
            path = objects(i).path;
            if objects(i).isBall
                if objects(i).lastSeen == k
                    drawBox(objects(i).box, 'b');
                end
                drawPath(path, 'b');
            else
                if objects(i).lastSeen == k
                    drawBox(objects(i).box, 'r');
                end
                drawPath(path, 'r');
            end
            % Draw highest point
            [p1, p2] = size(path);
            if p1 > 2 && objects(i).highest == 0 && objects(i).isBall
                if drawHighest(path)
                    objects(i).highest = path(end, 2);
                    needPause = 1;
                end
            end
        end
        if needPause == 1
            pause(3);
        end
    end

% update the buffer for past frames
    function updateFrameBuffer()
        if LOOK_BACK > 1
            for i = LOOK_BACK : -1 : 2
                frameBuff(:, :, :, i) = frameBuff(:, :, :, i-1);
            end
        end
        frameBuff(:, :, :, 1) = frameD;
    end

% update the objects structure by assignining/adding the objects
% detected in the current frame
    function updateObjectsStruct()
        centres = cat(1, props.Centroid);
        
        for i = 1 : size(centres,1)
            assigned = false;
            c1 = min(centres(i, 1),x-1);
            c2 = min(centres(i, 2),y-1);
            centrePixel=im2double(frame(uint8(c1),uint8(c2),:));
            currCentreColour = bsxfun(@rdivide, centrePixel, sum(centrePixel,3,'native'));
            for j = 1 : size(objects, 2)
                if objects(j).lastSeen < k
                    x1 = objects(j).path(end,1);
                    y1 = objects(j).path(end,2);
                    
                    dist = distance(x1,c1,y1,c2);
                    
                    if dist < 20 && isCloseRGBVal(objects(j).colour, currCentreColour,5)
                        objects(j).path = [objects(j).path; [c1 c2]];
                        objects(j).lastSeen = k;
                        objects(j).colour = currCentreColour;
                        objects(j).box = props(i).BoundingBox;
                        vel = objects(j).path(end-1, 2) - objects(j).path(end, 2);
                        if ~objects(j).isBall && vel > -1 && isBall(props(i).Perimeter, props(i).Area, props(i).Eccentricity, MIN_AREA)
                            if objects(j).ballCount == BALL_FOR_SURE
                                objects(j).isBall = true;
                            else
                                objects(j).ballCount = objects(j).ballCount + 1;
                            end
                        end
                        assigned = true;
                    end
                end
            end
            if ~assigned
                objects(end + 1) = struct('path', [[c1 c2]], 'lastSeen', k, 'colour', currCentreColour, 'highest', 0, 'box', props(i).BoundingBox, 'isBall', false, 'ballCount', 0);
            end
        end
    end

% remove lost objects from objects struct
    function removeLostObjects()
        rm = [];
        for i = 1 : size(objects, 2)
            if(objects(i).lastSeen < k-10)
                Highest = objects(i).highest
                min(objects(i).path(:,2))
                rm = [rm i];
            end
        end
        objects(rm) = [];
    end

% check two rgb pixels if they are close enough.
    function is = isCloseRGBVal(pixel1, pixel2,thresh)
        is = true;
        if abs(pixel1(1, 1, 1) - pixel2(1, 1, 1)) > thresh
            is = false;
        end
        
        if abs(pixel1(1, 1, 2) - pixel2(1, 1, 2)) > thresh
            is = false;
        end
        
        if abs(pixel1(1, 1, 3) - pixel2(1, 1, 3)) > thresh
            is = false;
        end
    end
end