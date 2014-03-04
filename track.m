function track(file_dir,learnSize,minArea,lookBack,view)

if minArea<50
    minArea=50;
end
filenames = dir([file_dir '*.jpg']);

frame = imread([file_dir filenames(1).name]);
figure(1);

x = size(frame,1);
y = size(frame,2);

objects = struct('path', {}, 'lastSeen', {}, 'colour', {}, 'highest', 0, 'box', {}, 'isBall', {});

backgroundSum = double(zeros(x, y, 3));
foreground = zeros(x, y);
diff = zeros(x, y);
updated = 0;
frameD = double(frame);

frameBuff(:,:,:,1)=frameD;
if(lookBack>0)
    frameBuff(:,:,:,lookBack)=frameD;
end

% play 'video'
for k = 150 : size(filenames, 1)
    frame = imread([file_dir filenames(k).name]);
    frameD = double(frame);
    %normalised = bsxfun(@rdivide, im2double(frame), sum(im2double(frame),3,'native'));
    if k<=learnSize
        updated=updated+1;
        backgroundSum=frameD+backgroundSum;
    end
    if k==learnSize
        background=backgroundSum/learnSize;
    end
    if k>=learnSize && lookBack>0
        %  background=backgroundSum/updated;
    end
    if k>learnSize
        props = extractForegroundObjects();
        % show frame
        if view == 0
            imshow(frame);
            
        else
            d=diff*255;
            
            f=foreground*255;
            bwims = cat(2, cat(3,f,f,f), cat(3,d,d,d));
            imshow(cat(2,frame,bwims));
        end
        centres = cat(1, props.Centroid);
        updateObjectsStruct();
        removeLostObjects();
        drawInfo();
        
    end
    
    if k > learnSize && lookBack > 0
        diff=zeros(x, y);
        diff(abs(frameD(:, :, 1) - frameBuff(:, :, 1, lookBack)) > 5) = 1;
        diff(abs(frameD(:, :, 2) - frameBuff(:, :, 2, lookBack)) > 5) = 1;
        diff(abs(frameD(:, :, 3) - frameBuff(:, :, 3, lookBack)) > 5) = 1;
        diff = bwmorph(diff, 'erode', 2);
        
        if diff == zeros(x,y)
            background = (background + 2*frameD)/3;
            updated = updated + 1;
            
        end
    end
    
    if lookBack > 0
        updateFrameBuffer();
    end
    %imShow(frame);
    
    
    drawnow('expose');
end

    % this function compares the current frame to the estimated backgroung value and returns the finds foreground objects
    function props = extractForegroundObjects()
        foreground = zeros(x,y);
        foreground(abs(frameD(:, :, 1) - background(:, :, 1)) > 8) = 1;
        foreground(abs(frameD(:, :, 2) - background(:, :, 2)) > 8) = 1;
        foreground(abs(frameD(:, :, 3) - background(:, :, 3)) > 8) = 1;
        
        % Filters
        foreground = bwmorph(foreground, 'erode', 1);
        foreground = bwmorph(foreground, 'close', Inf);
        foreground = medfilt2(foreground);
        
        % Get information about the objects
        labels = bwlabel(foreground, 4);
        props = regionprops(labels, 'centroid', 'perimeter', 'area', 'boundingbox', 'eccentricity', 'conveximage');
        
        % Remove small objects (noise)
        rm = [];
        for i = 1 : length(props)
            if props(i).Area < minArea
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
            if p1 > 2 && ~objects(i).highest && objects(i).isBall
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

    % update the buffer for past frames
    function updateFrameBuffer()
        if lookBack > 1
            for i = lookBack : -1 : 2
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
            centrePixel=im2double(frame(uint8(centres(i, 1)),uint8(centres(i, 2)),:));
            currCentreColour = bsxfun(@rdivide, centrePixel, sum(centrePixel,3,'native'));
            for j = 1 : size(objects, 2)
                if objects(j).lastSeen < k
                    x1 = objects(j).path(end,1);
                    y1 = objects(j).path(end,2);
                    x2 = centres(i,1);
                    y2 = centres(i,2);
                    dist = distance(x1,x2,y1,y2);
                    
                    if dist < 20 && isCloseRGBVal(objects(j).colour, currCentreColour,5)
                        objects(j).path = [objects(j).path; [centres(i, 1) centres(i,2)]];
                        objects(j).lastSeen = k;
                        objects(j).colour = currCentreColour;
                        objects(j).box = props(i).BoundingBox;
                        if ~objects(j).isBall && isBall(props(i).Perimeter, props(i).Area, props(i).Eccentricity, props(i).ConvexImage)
                            objects(j).isBall = true;
                            
                        end
                        assigned = true;
                    end
                end
            end
            if ~assigned
                objects(end + 1) = struct('path', [[centres(i, 1) centres(i,2)]], 'lastSeen', k, 'colour', currCentreColour, 'highest', 0, 'box', props(i).BoundingBox, 'isBall', false);
            end
        end 
    end

    % remove lost objects from objects struct
    function removeLostObjects()
        rm = [];
        for i = 1 : size(objects, 2)
            if(objects(i).lastSeen < k-10)
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