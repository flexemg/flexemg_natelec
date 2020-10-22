close all
clear
clc

files = dir('./realtime_data/*.mat');
numGest = 13;

centerPoint = 301;
onsetTime = -300:300;
onsetAlignedPred = nan(length(onsetTime),numGest,length(files));
onsetAlignedGnd = onsetAlignedPred;

offsetTime = -300:300;
offsetAlignedPred = nan(length(offsetTime),numGest,length(files));
offsetAlignedGnd = offsetAlignedPred;


for f = 1:length(files)
    load([files(f).folder '/' files(f).name]);
    session = experiment(2).trials;
    
    % separate analysis for rest
    onset = get_onset_chgpts(session(1));
    idx = (1:length(session(1).prediction)) - onset + centerPoint;
    onsetAlignedPred(idx,1,f) = session(1).prediction;
    onsetAlignedGnd(idx,1,f) = 100;
    
    offset = get_offset_chgpts(session(1));
    idx = (1:length(session(1).prediction)) - offset + centerPoint;
    offsetAlignedPred(idx,1,f) = session(1).prediction;
    offsetAlignedGnd(idx,1,f) = 100;
    
    for g = 2:numGest
        gndTruth = get_gnd_truth_chgpts(session(g));
        
        onset = get_onset_chgpts(session(g));
        if ~isnan(onset) && (onset > 20) && (onset < 70)
            idx = (1:length(session(g).prediction)) - onset + centerPoint;
            onsetAlignedPred(idx,g,f) = session(g).prediction;
            onsetAlignedGnd(idx,g,f) = gndTruth;
        end
        
        offset = get_offset_chgpts(session(g));
        if ~isnan(offset) && (offset > 150) && (offset < 200)
            idx = (1:length(session(g).prediction)) - offset + centerPoint;
            offsetAlignedPred(idx,g,f) = session(g).prediction;
            offsetAlignedGnd(idx,g,f) = gndTruth;
        end
    end
end

plotStart = -30;
plotEnd = 30;
        
onsetRest = zeros(length(onsetTime),numGest,length(files));
onsetCorrect = zeros(length(onsetTime),numGest,length(files));
onsetError = zeros(length(onsetTime),numGest,length(files));

offsetRest = zeros(length(onsetTime),numGest,length(files));
offsetCorrect = zeros(length(onsetTime),numGest,length(files));
offsetError = zeros(length(onsetTime),numGest,length(files));

for g = 1:numGest
    for f = 1:length(files)
        onsetRest(:,g,f) = onsetAlignedPred(:,g,f) == 100;
        onsetCorrect(:,g,f) = onsetAlignedPred(:,g,f) == 99+g;
        onsetError(:,g,f) = (onsetAlignedPred(:,g,f) ~= 100) & (onsetAlignedPred(:,g,f) ~= 99+g) & ~isnan(onsetAlignedPred(:,g,f));
        offsetRest(:,g,f) = offsetAlignedPred(:,g,f) == 100;
        offsetCorrect(:,g,f) = offsetAlignedPred(:,g,f) == 99+g;
        offsetError(:,g,f) = (offsetAlignedPred(:,g,f) ~= 100) & (offsetAlignedPred(:,g,f) ~= 99+g) & ~isnan(offsetAlignedPred(:,g,f));
    end
end

onsetRest = sum(onsetRest(:,2:end,:),[2 3]);
onsetError = sum(onsetError(:,2:end,:),[2 3]);
onsetCorrect = sum(onsetCorrect(:,2:end,:),[2 3]);

offsetRest = sum(offsetRest(:,2:end,:),[2 3]);
offsetError = sum(offsetError(:,2:end,:),[2 3]);
offsetCorrect = sum(offsetCorrect(:,2:end,:),[2 3]);

offsetStats = [offsetRest offsetError offsetCorrect]./repmat(offsetRest+offsetError+offsetCorrect,1,3);
onsetStats = [onsetRest onsetError onsetCorrect]./repmat(onsetRest+onsetError+onsetCorrect,1,3);

figure
set(gcf,'position',[700 700 900 200])
area(onsetTime.*50,onsetStats)
xlim([plotStart plotEnd].*50)

figure
set(gcf,'position',[700 700 900 200])
area(offsetTime.*50,offsetStats)
xlim([plotStart plotEnd].*50)

for g = 1:numGest
    
    vals = zeros(numGest,length(onsetTime));
    preds = squeeze(onsetAlignedPred(:,g,:));
    gndTruth = mode(squeeze(onsetAlignedGnd(:,g,:)),2);
    for gLabel = 1:numGest
        vals(gLabel,:) = sum(preds == gLabel + 99,2);
    end
    vals = vals./(repmat(sum(vals),numGest,1));
    imTime = onsetTime(sum(isnan(vals))==0);
    gndTruth = gndTruth(sum(isnan(vals))==0)-99;
    vals = vals(:,sum(isnan(vals))==0);
    
    pixW = 9;
    pixL = 9;
    lineW = 1;
    
    imW = numGest*pixW + (numGest+1)*lineW;
    imL = length(vals)*pixL + (length(vals)+1)*lineW;
    im = uint8(255*ones(imW,imL,3));
    
    for x = 1:numGest
        for y = 1:length(vals)
            cornerX = lineW + (lineW + pixW)*(x-1)+1;
            cornerY = lineW + (lineW + pixL)*(y-1)+1;
            if gndTruth(y) == x
                im(cornerX:cornerX+pixW-1,cornerY:cornerY+pixL-1,[1 3]) = 255 - round(vals(x,y).*255);
            else
                im(cornerX:cornerX+pixW-1,cornerY:cornerY+pixL-1,[2 3]) = 255 - round(vals(x,y).*255);
            end
        end
    end
    onsetX = (1:lineW) + (find(imTime>0,1)-1)*(pixL+lineW);
    im(:,onsetX,:) = 0;
    im(:,onsetX,3) = 255;
    
    startX = (1:lineW) + (find(imTime == plotStart)-1)*(pixL+lineW);
    if isempty(startX)
        startX = 1;
    else
        im(:,startX,:) = 0;
    end
    stopX = (1:lineW) + (find(imTime == plotEnd)-1)*(pixL+lineW);
    if isempty(stopX)
        stopX = imL;
    else
        im(:,stopX,:) = 0;
    end
    
    im(1:lineW,:,:) = 0;
    im(end-lineW+1:end,:,:) = 0;
    im(:,1:lineW,:) = 0;
    im(:,end-lineW+1:end,:) = 0;
    
    im = im(:,startX:stopX,:);
    
    imwrite(im,['./realtime_figure_outputs/G' num2str(g) '_onset.png']);
end

for g = 1:numGest
    vals = zeros(numGest,length(offsetTime));
    preds = squeeze(offsetAlignedPred(:,g,:));
    gndTruth = mode(squeeze(offsetAlignedGnd(:,g,:)),2);
    for gLabel = 1:numGest
        vals(gLabel,:) = sum(preds == gLabel + 99,2);
    end
    vals = vals./(repmat(sum(vals),numGest,1));
    imTime = offsetTime(sum(isnan(vals))==0);
    gndTruth = gndTruth(sum(isnan(vals))==0)-99;
    vals = vals(:,sum(isnan(vals))==0);
    
    pixW = 9;
    pixL = 9;
    lineW = 1;
    
    imW = numGest*pixW + (numGest+1)*lineW;
    imL = length(vals)*pixL + (length(vals)+1)*lineW;
    im = uint8(255*ones(imW,imL,3));
    
    for x = 1:numGest
        for y = 1:length(vals)
            cornerX = lineW + (lineW + pixW)*(x-1)+1;
            cornerY = lineW + (lineW + pixL)*(y-1)+1;
            if gndTruth(y) == x
                im(cornerX:cornerX+pixW-1,cornerY:cornerY+pixL-1,[1 3]) = 255 - round(vals(x,y).*255);
            else
                im(cornerX:cornerX+pixW-1,cornerY:cornerY+pixL-1,[2 3]) = 255 - round(vals(x,y).*255);
            end
        end
    end
    onsetX = (1:lineW) + (find(imTime>0,1)-1)*(pixL+lineW);
    im(:,onsetX,:) = 0;
    im(:,onsetX,3) = 255;
    
    startX = (1:lineW) + (find(imTime == plotStart)-1)*(pixL+lineW);
    if isempty(startX)
        startX = 1;
    else
        im(:,startX,:) = 0;
    end
    stopX = (1:lineW) + (find(imTime == plotEnd)-1)*(pixL+lineW);
    if isempty(stopX)
        stopX = imL;
    else
        im(:,stopX,:) = 0;
    end
    
    im(1:lineW,:,:) = 0;
    im(end-lineW+1:end,:,:) = 0;
    im(:,1:lineW,:) = 0;
    im(:,end-lineW+1:end,:) = 0;
    
    im = im(:,startX:stopX,:);
    
    imwrite(im,['./realtime_figure_outputs/G' num2str(g) '_offset.png']);
end


%%
redBar = [ones(500,1) (1:500)'./500 (1:500)'./500];
greenBar = [(1:500)'./500 ones(500,1) (1:500)'./500];
figure
set(gcf,'position',[500 500 1000 150])
a1 = subplot(2,1,1);
imagesc(a1,1:500)
colormap(a1, redBar)
axis off
a2 = subplot(2,1,2);
imagesc(a2,500:-1:1)
colormap(a2, greenBar)
axis off