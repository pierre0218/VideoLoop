clear all;

loopableRegionFilename = 'palmtrees.mat';
inputVideoFilename = 'palmtrees.mp4';
outputVideoFilename = 'palmtrees_loop3.mp4';

 load(loopableRegionFilename)
% %% Initial Setting 
 v = VideoReader(inputVideoFilename);
 totalFrames = floor(v.Duration * v.FrameRate);
% %% Parameter
jump = 4;

label = round(imresize(labelsmooth,2));
loopableI = find(label == 2);
imgSize = size(label);

% % create loop
% % candidate periods are 8 ~ 30 frames

downSampledFrames = floor(totalFrames/jump);
p_candidates = 30:-1:10;

timer = tic;

finalSP = zeros(imgSize);
minErrors = inf(size(loopableI));

numOfsp = 0;
allSP = [];
for i=1:length(p_candidates)
    p = p_candidates(i);
    for s=2:downSampledFrames-p
        frame_s = rgb2gray(read(v,s));
        frame_p = rgb2gray(read(v,s+p));
        
        diff = abs(frame_p(loopableI)-frame_s(loopableI));
        
        minDiffI = find(diff < minErrors);
        minErrors(minDiffI) = diff(minDiffI);
        finalSP(loopableI(minDiffI)) = p*100+s;
        
        if(length(minDiffI) > 0)
            numOfsp = numOfsp +1;
            allSP(numOfsp) = p*100+s;
        end
    end
end
elapsedTime = toc(timer);
fprintf('elapsed time for finding s and p: %d seconds.\n',elapsedTime);

timer = tic;

% save input video frames to a struct
for time = 1:totalFrames
    InputVideo{time} = {read(v,time)};
end 

minT = inf;
maxT = 0;

for j = 1:length(allSP)
    minP = floor(allSP(j)/100);
    minS = allSP(j)-minP*100;
    
    sx = 1+jump*(minS-1);
    px = minP*jump;
    
    focusI = find(finalSP == allSP(j));

    integerMultiple = floor((totalFrames-sx+1)/(px+1));
    
    for t = sx:(sx+(px+1)*integerMultiple-1)
        if(t < minT)
            minT = t;
        end
        if(t > maxT)
            maxT = t;
        end
        
        phi_t = sx + mod((t-sx),(px+1));
        frame = InputVideo{t}{1};
        frame_phi = InputVideo{phi_t}{1};

        frameR = frame(:,:,1);
        frameG = frame(:,:,2);
        frameB = frame(:,:,3);

        frame_phiR = frame_phi(:,:,1);
        frame_phiG = frame_phi(:,:,2);
        frame_phiB = frame_phi(:,:,3);

        frameR(focusI) = frame_phiR(focusI);
        frameG(focusI) = frame_phiG(focusI);
        frameB(focusI) = frame_phiB(focusI);

        finalFrame = uint8(cat(3,frameR,frameG,frameB));

        InputVideo{t} = {finalFrame};
    end
end

vw = VideoWriter(outputVideoFilename,'MPEG-4');
open(vw);

for time = minT:maxT
    frame = InputVideo{time}{1};
    writeVideo(vw,frame);
end 

close(vw);

elapsedTime = toc(timer);
fprintf('elapsed time for creating video loop: %d seconds.\n',elapsedTime);
