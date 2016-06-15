clear all;

 load('palmtrees.mat')
% %% Initial Setting 
 v = VideoReader('palmtrees.mp4');
 totalFrames = floor(v.Duration * v.FrameRate);
% %% Parameter
jump = 4;
ratio = 1/2;

loopableI = find(labelsmooth == 2);

% % create loop
% % candidate periods are 8 ~ 30 frames

downSampledFrames = floor(totalFrames/jump);
p_candidates = 30:-1:10;

timer = tic;

minError = 1000;
minP = 1;
minS = 1;
errors = [];
for i=1:length(p_candidates)
    p = p_candidates(i);
    for s=2:downSampledFrames-p
        frame_s = rgb2gray(imresize(read(v,s), ratio));
        frame_p = rgb2gray(imresize(read(v,s+p), ratio));
        
        diff1 = abs(frame_p(loopableI)-frame_s(loopableI));
        
        frame_s = rgb2gray(imresize(read(v,s-1), ratio));
        frame_p = rgb2gray(imresize(read(v,s+p-1), ratio));
        
        diff2 = abs(frame_p(loopableI)-frame_s(loopableI));
        
        diff = sort(diff1+diff2);
        error = prctile(diff,90);
        
        if error < minError
            minError = error;
            minP = p;
            minS = s;
        end
    end
    errors(i) = minError;
    
end
elapsedTime = toc(timer);
fprintf('elapsed time for finding s and p: %d seconds.\n',elapsedTime);
fprintf('min s: %d and min p: %d.\n',minS, minP);
timer = tic;

vw = VideoWriter('palmtrees_loop.mp4','MPEG-4');
open(vw);

integerMultiple = floor((totalFrames-minS)/minP);
label = imresize(labelsmooth,2);
loopableI = find(label == 2);
 
for t = minS:minP*integerMultiple
    phi_t = minS + mod((t-minS),minP);
    frame = read(v,t);
    frame_phi = read(v,phi_t);
    
    frameR = frame(:,:,1);
    frameG = frame(:,:,2);
    frameB = frame(:,:,3);
    
    frame_phiR = frame_phi(:,:,1);
    frame_phiG = frame_phi(:,:,2);
    frame_phiB = frame_phi(:,:,3);
    
    frameR(loopableI) = frame_phiR(loopableI);
    frameG(loopableI) = frame_phiG(loopableI);
    frameB(loopableI) = frame_phiB(loopableI);
    
    finalFrame = cat(3,frameR,frameG,frameB);
    
    writeVideo(vw,finalFrame);
end

close(vw);

elapsedTime = toc(timer);
fprintf('elapsed time for creating video loop: %d seconds.\n',elapsedTime);
