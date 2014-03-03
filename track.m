function track(file_dir,learnSize,lookBack)

filenames = dir([file_dir '*.jpg']);

frame = imread([file_dir filenames(1).name]);
figure(1);

x=size(frame,1);
y=size(frame,2);

objects=struct('path',{},'lastSeen',{},'colour',{}, 'highest', 0, 'box', {}, 'isBall', {});

backgroundSum = double(zeros(x,y,3));
foreground=zeros(x,y);
diff=zeros(x,y);
updated=0;

frameBuff(:,:,:,1)=zeros(x,y,3);
if(lookBack>0)
    frameBuff(:,:,:,lookBack)=zeros(x,y,3);
end

% play 'video'
for k = 1 : size(filenames, 1)
    frame = imread([file_dir filenames(k).name]);
    frameD = double(frame);
    normalised = bsxfun(@rdivide, im2double(frame), sum(im2double(frame),3,'native'));
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
        d=diff*255;
        f=foreground*255;
        bwims = cat(2, cat(3,f,f,f), cat(3,d,d,d));
        imshow(cat(2,frame,bwims));
        centres = cat(1, props.Centroid);
        updateObjectsStruct();
        removeLostObjects();
        drawInfo();
    end
    
    if k>learnSize && lookBack>0
        diff=zeros(x,y);
        diff(abs(frameD(:,:,1)-frameBuff(:,:,1,lookBack)) > 5)=1;
        diff(abs(frameD(:,:,2)-frameBuff(:,:,2,lookBack)) > 5)=1;
        diff(abs(frameD(:,:,3)-frameBuff(:,:,3,lookBack)) > 5)=1;
        diff=bwmorph(diff, 'erode', 2);
        
        if(diff==zeros(x,y))
            %backgroundSum=frameD+backgroundSum;
            background=(background+2*frameD)/3;
            updated=updated+1;
            
        end
    end
    
    if(lookBack>0)
        updateFrameBuffer();
    end
    %imShow(frame);
    
    
    drawnow('expose');
end

% this function compares the current frame to the estimated backgroung value and returns the finds foreground objects
    function props = extractForegroundObjects()
        foreground = zeros(x,y);
        foreground(abs(frameD(:,:,1)-background(:,:,1)) > 8)=1;
        foreground(abs(frameD(:,:,2)-background(:,:,2)) > 8)=1;
        foreground(abs(frameD(:,:,3)-background(:,:,3)) > 8)=1;
        
        foreground = bwmorph(foreground, 'erode', 1);
        foreground = bwmorph(foreground, 'close', Inf);
        foreground = medfilt2(foreground);
        
        labels = bwlabel(foreground,4);
        props = regionprops(labels, 'centroid', 'perimeter', 'area', 'boundingbox', 'eccentricity');
        
        %remove small objects
        rm = [];
        for i = 1 : length (props)
            if props(i).Area < 50
                rm=[rm i];
            end
        end
        props(rm)=[];
        
        %imshow(foreground);
    end

% dispaly paths, centroids and centers for every object in objects struct
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
        if lookBack>1
            for i=lookBack : 2
                frameBuff(:,:,:,i)=frameBuff(:,:,:,i-1);
            end
        end
        frameBuff(:,:,:,1)=frameD;
    end

% update the objects structure by assignining/adding the objects
% detected in the current frame
    function updateObjectsStruct()
        centres = cat(1, props.Centroid);
        
        for i = 1 : size(centres,1)
            drawCentres([centres(i, 1) centres(i,2)]);
            assigned = false;
            
            for j = 1 : size(objects, 2)
                if(objects(j).lastSeen<k)
                    x1=objects(j).path(end,1);
                    y1=objects(j).path(end,2);
                    x2=centres(i,1);
                    y2=centres(i,2);
                    dist=distance(x1,x2,y1,y2);
                    currCentreColour=normalised(uint8(centres(i, 1)),uint8(centres(i,2)),:);
                    if(dist<15&&isCloseRGBVal(objects(j).colour,currCentreColour,1))
                        objects(j).path=[ objects(j).path ; [centres(i, 1) centres(i,2)]];
                        objects(j).lastSeen=k;
                        objects(j).colour=currCentreColour;
                        objects(j).box = props(i).BoundingBox;
                        if(isBall(props(i).Perimeter, props(i).Area, props(i).Eccentricity))
                            objects(j).isBall=true;
                        end
                        assigned=true;
                    end
                end
            end
            if ~assigned
                objects(end+1)=struct('path',[[centres(i, 1) centres(i,2)]],'lastSeen',k,'colour',normalised(uint8(centres(i, 1)),uint8(centres(i,2)),:), 'highest', 0, 'box', props(i).BoundingBox, 'isBall', false);
            end
        end
        
        
    end

% remove lost objects from objects struct
    function removeLostObjects()
        rm=[];
        for i=1 : size(objects,2)
            if(objects(i).lastSeen<k-10)
                rm=[rm i];
            end
        end
        objects(rm)=[];
    end

% check two rgb pixels if they are close enough.
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