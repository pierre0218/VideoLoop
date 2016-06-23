clear all;
loopableRegionFilename = 'gibbonfalls.mat';
inputVideoFilename = 'gibbonfalls.mp4';

outputVideoFilename = 'gibbonfalls_loop.mp4';

 load(loopableRegionFilename)
% %% Initial Setting 
 v = VideoReader(inputVideoFilename);
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

minError = inf;
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
         len = length(diff);
         len = floor(len*4/5); % get only 80 percent of errors
         error = sum(diff(1:len,:));
        
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

vw = VideoWriter(outputVideoFilename,'MPEG-4');
open(vw);

sx = 1+jump*(minS-1);
px = minP*jump;

integerMultiple = floor((totalFrames-sx+1)/(px+1));
label = round(imresize(labelsmooth,2));
loopableI = find(label == 2);

for t = sx:(sx+(px+1)*integerMultiple-1)
    phi_t = sx + mod((t-sx),(px+1));
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
