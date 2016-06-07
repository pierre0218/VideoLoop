v = VideoReader('palmtrees.mp4');

totalFrames = floor(v.Duration * v.FrameRate);

diff = 0;
for i=1:totalFrames-1
    f1 = rgb2gray(read(v,i));
    f2 = rgb2gray(read(v,i+1));
    diff = diff + f2-f1;
end

[rowDiff, colDiff]=find(diff>5);
totalPixel = size(diff,1)*size(diff,2);
loopPixel = size(rowDiff,1);
staticPixel = totalPixel - loopPixel;
fprintf('Total Pixel= %d, Loop Pixel= %d, zeros Pixel= %d\n',...
    totalPixel, loopPixel, staticPixel);

imshow(diff);