clear all;

%% Initial Setting 
v = VideoReader('palmtrees.mp4');
totalFrames = floor(v.Duration * v.FrameRate);
%% Parameter
jump = 4; threshold = 10;%10/255;
ratio = 1/2;

%% DownSample classifier

minR = [];
minG = [];
minB = [];

maxR = [];
maxG = [];
maxB = [];

f = imresize(read(v,1), ratio);
imgSize = size(f);
minR = f(:,:,1);
minG = f(:,:,2);
minB = f(:,:,3);

maxR = f(:,:,1);
maxG = f(:,:,2);
maxB = f(:,:,3);

risesR = [];
risesG = [];
risesB = [];

fallsR = [];
fallsG = [];
fallsB = [];

for i=2:jump:totalFrames
    f = imresize(read(v,i), ratio);
    fR = f(:,:,1);
    fG = f(:,:,2);
    fB = f(:,:,3);
    
    fallsI = find(maxR-fR > threshold);
    fallsR = union(fallsR,fallsI);
    
    fallsI = find(maxG-fG > threshold);
    fallsG = union(fallsG,fallsI);
    
    fallsI = find(maxB-fB > threshold);
    fallsB = union(fallsB,fallsI);
    
    risesI = find(fR - minR > threshold);
    risesR = union(risesR,risesI);
    
    risesI = find(fG - minG > threshold);
    risesG = union(risesG,risesI);
    
    risesI = find(fB - minB > threshold);
    risesB = union(risesB,risesI);

    ir = find(fR < minR);
    minR(ir) = fR(ir); 
    ig = find(fG < minG);
    minG(ig) = fG(ig); 
    ib = find(fB < minB);
    minB(ib) = fB(ib); 
    
    ir = find(fR > maxR);
    maxR(ir) = fR(ir); 
    ig = find(fG > maxG);
    maxG(ig) = fG(ig); 
    ib = find(fB > maxB);
    maxB(ib) = fB(ib); 
end
allIndex = 1:imgSize(1)*imgSize(2);
temp1 = union(risesR, fallsR);
temp2 = union(risesG, fallsG);
temp3 = union(risesB, fallsB);

temp4 = union(temp1,temp2);
temp5 = union(temp3,temp4);

unchangingI = setdiff(allIndex,temp5);

temp1 = setxor(risesR, fallsR);
temp2 = setxor(risesG, fallsG);
temp3 = setxor(risesB, fallsB);

temp4 = union(temp1,temp2);
unloopableI = union(temp3,temp4);
loopableI = setdiff(allIndex,unchangingI);
loopableI = setdiff(loopableI,unloopableI);

label = zeros([imgSize(1) imgSize(2)]);
label(loopableI) = 2;
label(unchangingI) = 1;

labelsmooth = round(imgaussfilt(label,2));
img = labelsmooth/2;

imshow(img);
