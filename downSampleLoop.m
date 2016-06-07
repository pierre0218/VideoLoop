v = VideoReader('palmtrees.mp4');
totalFrames = floor(v.Duration * v.FrameRate);

diff = 0; jump = 4; threshold = 10/255;

label = zeros(600,1000,totalFrames/jump);
for i=1:jump:totalFrames-jump
    f1 = imresize(rgb2gray(read(v,i)), 1/2);
    f2 = imresize(rgb2gray(read(v,i+jump)),1/2);
    for row=1:size(f1,1)
        for col=1:size(f1,1)
            elementDiff = f2(row,col)- f1(row,col);
            if (elementDiff>threshold)
                % +2 means rise
                label(row,col,jump) =2;
            elseif (abs(elementDiff)>threshold)
                % +1 means falls
                label(row,col,jump)=1  ;
            end
        end
    end
end



% [rowDiff, colDiff]=find(diff>5);
% totalPixel = size(diff,1)*size(diff,2);
% loopPixel = size(rowDiff,1);
% staticPixel = totalPixel - loopPixel;
% fprintf('Total Pixel= %d, Loop Pixel= %d, zeros Pixel= %d\n',...
%     totalPixel, loopPixel, staticPixel);
% 
% imshow(diff);