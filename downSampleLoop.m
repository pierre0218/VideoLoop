%% Initial Setting 
v = VideoReader('palmtrees.mp4');
totalFrames = floor(v.Duration * v.FrameRate);
%% Parameter
jump = 4; threshold = 10; % 10/255
ratio = 1/2;

%% DownSample classifier
diff = [];
label = zeros(v.Height * ratio,v.Width * ratio,totalFrames/jump);
for i=1:jump:totalFrames-jump
    f1 = imresize(rgb2gray(read(v,i)), ratio);
    f2 = imresize(rgb2gray(read(v,i+jump)),ratio);
    for row=1:size(f1,1)
        for col=1:size(f1,1)
            elementDiff = f2(row,col)- f1(row,col);
%             diff=[diff;elementDiff];
            if (elementDiff > 0)
                % +2 means rise
                if (elementDiff > threshold) 
                    label(row,col,jump) =2;
                end
            elseif (elementDiff < 0)
                fprintf('I''Here\n');
                if (abs(elementDiff) >threshold)
                % +1 means falls
                    label(row,col,jump)=1  ;
                end
            end
        end
    end
end

clear f1 f2 elementDiff

%% imgLabel: -1 Static,  0 unloopable, 1 loopable
imgLabel = zeros(v.height * ratio, v.width*ratio);
fptr = fopen('log_imgLabel.txt','w');
for row =1:size(label,1)
    for col=1:size(label,2)
        tmp = reshape(label(row,col,:),[],1);
        tmpValue =  unique(tmp);
        fprintf(fptr, 'row= %d, col=%d\n', row,col);
        fprintf(fptr, '%d ',tmpValue);
        fprintf(fptr, '\n--------\n');
        if (sum(tmp)==0)
            imgLabel(row,col)=-1;
        elseif not(find(tmpValue==0))
            imgLabel(row,col) = 1;
        else
            imgLabel(row,col)=0;
        end 
    end
end

[rowLoop, colLoop]=find(imgLabel==1);
[rowStatic, colStatic] = find(imgLabel==-1);
[rowUnloop, colUnloop] = find(imgLabel==0); 

fprintf('Total Pixel= %d, Loop Pixel= %d, Static Pixel= %d, Unloop Pixel= %d\n',size(label,1) * size(label,2) , size(rowLoop,1), size(rowStatic,1), size(rowUnloop,1) );
fclose('all');