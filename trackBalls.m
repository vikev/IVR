function trackBalls(file_dir,learnSize)

filenames = dir([file_dir '*.jpg']);

frame = imread([file_dir filenames(1).name]);
figure(1);

x=size(frame,1);
y=size(frame,2)
p=0.01;
m=2.5;
imshow(frame);
drawnow('expose');

gray5= rgb2gray(imread([file_dir filenames(1).name]));
gray4=rgb2gray(imread([file_dir filenames(2).name]));
gray3=rgb2gray(imread([file_dir filenames(3).name]));
gray2=rgb2gray(imread([file_dir filenames(4).name]));
gray1=rgb2gray(imread([file_dir filenames(5).name]));

for k = 20 : size(filenames, 1)
    frame = imread([file_dir filenames(k).name]);
    gr=rgb2gray(imread([file_dir filenames(k-3).name]));
    % Show frame
    gray = rgb2gray(frame);
    
    im=abs(gray-gr);
    im(im<5)=0;
    im(im>0)=255;
    im=im2bw(im);
    im=bwmorph(im, 'erode', 1);
    gray5=gray4;
    gray4=gray3;
    gray3=gray2;
    gray2=gray1;
    gray1=gray;
    
    im=imcomplement(im);
    figure(1);
    imshow(im);
    figure(2);
    imshow(frame);
    drawnow('expose');
    
end

end