v = VideoReader('palmtrees.mp4');

totalFrames = floor(v.Duration * v.FrameRate);

for i=1:totalFrames-1
f1 = read(v,i);
f2 = read(v,i+1);
diff = diff + f2-f1;
end


imshow(diff);