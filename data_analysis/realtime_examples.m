close all
clear
clc

% where to look for files
files = dir('./realtime_data/*.mat');

% select specific sessions to visualize
goodSessions = ["test"];
goodExperiments = ["s1_pw3.mat"];

% rough anatomic order of features
featOrder = [35 34 33 32 39 38 37 36 43 42 41 40 47 46 45 44 51 50 49 48 55 54 53 52 59 58 57 56 63 62 61 60 0:31] + 1;

for f = files'
    if matches(f.name,goodExperiments)
        load([f.folder '/' f.name]);
        for s = 1:length(experiment)
            if matches(experiment(s).description,goodSessions) && (length(experiment(s).trials) == 13)
                session = experiment(s).trials;

                % get max length of sessions
                maxLen = 0;
                for g = 1:length(session)
                    maxLen = max([maxLen length(session(g).prediction)]);
                end
                
                % get aligned statistics
                alignPoint = maxLen + 1;
                time = (1:(2*maxLen)) - alignPoint;
                onsetAlignedStats = zeros(2*maxLen,3);
                offsetAlignedStats = zeros(2*maxLen,3);
                onsetAlignedPredictions = nan(2*maxLen,length(session));
                offsetAlignedPredictions = nan(2*maxLen,length(session));
                onsetAlignedFeatures = nan(2*maxLen,64,length(session));
                offsetAlignedFeatures = nan(2*maxLen,64,length(session));

                for g = 2:length(session)
%                     onset = find(diff(session(g).offlineLabel) > 0);
                    onset = get_onset_chgpts(session(g));
                    if ~isempty(onset)
                        if onset > 0
                            idx = (1:length(session(g).prediction)) - onset + alignPoint;
                            onsetAlignedStats(idx,1) = onsetAlignedStats(idx,1) + double(session(g).prediction == 100);
                            onsetAlignedStats(idx,2) = onsetAlignedStats(idx,2) + double(session(g).prediction == session(g).gesture);
                            onsetAlignedStats(idx,3) = onsetAlignedStats(idx,3) + double((session(g).prediction ~= 100) & (session(g).prediction ~= session(g).gesture));
                            onsetAlignedPredictions(idx,g) = session(g).prediction;
                            onsetAlignedFeatures(idx,:,g) = session(g).features;
                        end
                    end
%                     offset = find(diff(session(g).offlineLabel) < 0);
                    offset = get_offset_chgpts(session(g));
                    if ~isempty(offset)
                        if offset > 0
                            idx = (1:length(session(g).prediction)) - offset + alignPoint;
                            offsetAlignedStats(idx,1) = offsetAlignedStats(idx,1) + double(session(g).prediction == 100);
                            offsetAlignedStats(idx,2) = offsetAlignedStats(idx,2) + double(session(g).prediction == session(g).gesture);
                            offsetAlignedStats(idx,3) = offsetAlignedStats(idx,3) + double((session(g).prediction ~= 100) & (session(g).prediction ~= session(g).gesture));
                            offsetAlignedPredictions(idx,g) = session(g).prediction;
                            offsetAlignedFeatures(idx,:,g) = session(g).features;
                        end
                    end
                end

                onsetAlignedStats = onsetAlignedStats./repmat(sum(onsetAlignedStats,2),1,3);
                onsetIdx = find(~isnan(onsetAlignedStats(:,1)),1):find(~isnan(onsetAlignedStats(:,1)),1,'last');
                onsetAlignedStats = onsetAlignedStats(onsetIdx,:);
                onsetAlignedPredictions = onsetAlignedPredictions(onsetIdx,:);
                onsetAlignedFeatures = onsetAlignedFeatures(onsetIdx,:,:);
                onsetTime = time(onsetIdx);
                offsetAlignedStats = offsetAlignedStats./repmat(sum(offsetAlignedStats,2),1,3);
                offsetIdx = find(~isnan(offsetAlignedStats(:,1)),1):find(~isnan(offsetAlignedStats(:,1)),1,'last');
                offsetAlignedStats = offsetAlignedStats(offsetIdx,:);
                offsetAlignedPredictions = offsetAlignedPredictions(offsetIdx,:);
                offsetAlignedFeatures = offsetAlignedFeatures(offsetIdx,:,:);
                offsetTime = time(offsetIdx);
                
                % rank maximally distant gestures
                numGest = length(session);
                gestFeatures = [];
                restFeat = mean(session(1).features(71:150,:));
                for g = 1:numGest
                     temp = mean(session(g).features(71:150,:)) - restFeat;
                     gestFeatures(end+1,:) = abs(temp)./max(abs(temp));
                end
                gestDists = get_cosine_similarities(gestFeatures');
                
                % get top pair
                [g1,g2] = ndgrid(1:numGest,1:numGest);
                [~,idx] = min(gestDists(:));
                gestures = [g1(idx),g2(idx)];
                
                for g = 3:numGest
                    subGestDists = gestDists(gestures,setdiff(1:numGest,gestures));
                    subG1 = g1(gestures,setdiff(1:numGest,gestures));
                    subG2 = g2(gestures,setdiff(1:numGest,gestures));
                    [~,idx] = min(subGestDists(:));
                    gestures(end+1) = subG2(idx);
                end

                gestures = gestures(1:4);

                % build experiment-aligned image
                numFeat = 64;
                gestWidth = 20;
                gestLength = 9;
                lineWidth = 1;
                featWidth = 4;
                featLength = 10;

                smallSpace = 20;
                largeSpace = 50;

                fullIm = [];
                maxL = maxLen*gestLength + maxLen + 1;
                for g = gestures
                    % add features first
                    imW = numFeat*featWidth;
                    imL = size(session(g).features,1)*featLength;
                    im = uint8(255*ones(imW,imL,1));
                    for n = 1:size(session(g).features,1)
                        for i = 1:numFeat
                            cornerX = featWidth*(i-1)+1;
                            cornerY = featLength*(n-1)+1;
                            im(cornerX:cornerX+featWidth-1,cornerY:cornerY+featLength-1,:) = session(g).features(n,featOrder(i))*4;
                        end
                    end
                    im = ind2rgb8(im,jet(256));
                    padL = maxL - imL;
                    if padL > 0
                        im = cat(2,im,255.*ones(imW,padL,3));
                    end
                    fullIm = cat(1,fullIm,im);

                    % add space between features and predictions
                    im = uint8(255*ones(smallSpace,maxL,3));
                    fullIm = cat(1,fullIm,im);

                    % add predictions
                    imW = numGest*gestWidth + (numGest+1)*lineWidth;
                    imL = length(session(g).prediction)*gestLength + (length(session(g).prediction)+1)*lineWidth;
                    im = uint8(255*ones(imW,imL,3));

                    trans = find(session(g).blindLabel == 0);
                    for i = 1:length(trans)
                        for idx = 1:numGest
                            cornerX = lineWidth + (lineWidth + gestWidth)*(idx-1)+1;
                            cornerY = lineWidth + (lineWidth + gestLength)*(trans(i)-1)+1;
                            im(cornerX:cornerX+gestWidth-1,cornerY:cornerY+gestLength-1,:) = 240;
                        end
                    end

                    relax = [1:min(trans)-1 max(trans)+1:length(session(g).prediction)];
                    for i = 1:length(relax)
                        for idx = 1:numGest
                            cornerX = lineWidth + (lineWidth + gestWidth)*(idx-1)+1;
                            cornerY = lineWidth + (lineWidth + gestLength)*(relax(i)-1)+1;
                            im(cornerX:cornerX+gestWidth-1,cornerY:cornerY+gestLength-1,:) = 220;
                        end
                    end

                    if session(g).gesture ~= 100
%                         onset = find(diff(session(g).offlineLabel) > 0);
%                         offset = find(diff(session(g).offlineLabel) < 0);
                        onset = get_onset_chgpts(session(g));
                        offset = get_offset_chgpts(session(g));

                        im(:,(1:lineWidth) + (onset)*(lineWidth+gestLength),1) = 0;
                        im(:,(1:lineWidth) + (onset)*(lineWidth+gestLength),2) = 0;
                        im(:,(1:lineWidth) + (onset)*(lineWidth+gestLength),3) = 255;

                        im(:,(1:lineWidth) + (offset)*(lineWidth+gestLength),1) = 0;   
                        im(:,(1:lineWidth) + (offset)*(lineWidth+gestLength),2) = 0;   
                        im(:,(1:lineWidth) + (offset)*(lineWidth+gestLength),3) = 255;   
                    end

                    % fill in the colors
                    gndTruth = get_gnd_truth_chgpts(session(g));
                    for n = 1:length(session(g).prediction)
                        idx = session(g).prediction(n) - 99;
                        cornerX = lineWidth + (lineWidth + gestWidth)*(idx-1)+1;
                        cornerY = lineWidth + (lineWidth + gestLength)*(n-1)+1;
                        im(cornerX:cornerX+gestWidth-1,cornerY:cornerY+gestLength-1,:) = 0;
                        if gndTruth(n) == session(g).prediction(n)
                            im(cornerX:cornerX+gestWidth-1,cornerY:cornerY+gestLength-1,2) = 255;
                        else
                            im(cornerX:cornerX+gestWidth-1,cornerY:cornerY+gestLength-1,1) = 255;
%                             if mode(session(g).gesture ~= 100) && ismember(n,trans) && ismember(session(g).prediction(n),gndTruth)
%                                 im(cornerX:cornerX+gestWidth-1,cornerY:cornerY+gestLength-1,2) = 160;
%                             end
                        end     
                    end
                    im(1:lineWidth,:,:) = 0;
                    im(end-lineWidth+1:end,:,:) = 0;
                    im(:,1:lineWidth,:) = 0;
                    im(:,end-lineWidth+1:end,:) = 0;
                    padL = maxL - imL;
                    if padL > 0
                        im = cat(2,im,255.*ones(imW,padL,3));
                    end
                    fullIm = cat(1,fullIm,im);

                    % add space between gestures
                    im = uint8(255*ones(largeSpace,maxL,3));
                    fullIm = cat(1,fullIm,im);
                end
                figure(1)
                imshow(fullIm);
                axis equal
                imwrite(fullIm,['./realtime_figure_outputs/' f.name(1:end-4) '_' experiment(s).description '_' regexprep(num2str(gestures), ' +', '-') '.png'])
                
                % plot onset aligned predictions
                plotStart = -50;
                plotEnd = 50;
                gestWidth = 5;
                gestLength = 20;
                lineWidth = 1;
                smallSpace = 10;
                fullIm = [];
                for g = 2:numGest
                    imW = numGest*gestWidth + (numGest+1)*lineWidth;
                    imL = size(onsetAlignedPredictions,1)*gestLength + (size(onsetAlignedPredictions,1)+1)*lineWidth;
                    im = uint8(255*ones(imW,imL,3));
                    pred = onsetAlignedPredictions(:,g);
                    gndTruth = 100.*ones(size(pred));
                    gndTruth(onsetTime>0) = g+99;
                    for n = 1:length(pred)
                        if ~isnan(pred(n))
                            idx = pred(n) - 99;
                            cornerX = lineWidth + (lineWidth + gestWidth)*(idx-1)+1;
                            cornerY = lineWidth + (lineWidth + gestLength)*(n-1)+1;
                            im(cornerX:cornerX+gestWidth-1,cornerY:cornerY+gestLength-1,:) = 0;
                            if gndTruth(n) == pred(n)
                                im(cornerX:cornerX+gestWidth-1,cornerY:cornerY+gestLength-1,2) = 255;
                            else
                                im(cornerX:cornerX+gestWidth-1,cornerY:cornerY+gestLength-1,1) = 255;
                            end
                        end
                    end
                    im(1:lineWidth,:,:) = 0;
                    im(end-lineWidth+1:end,:,:) = 0;
                    im(:,1:lineWidth,:) = 0;
                    im(:,end-lineWidth+1:end,:) = 0;
                    
                    onsetX = (1:lineWidth) + (find(onsetTime>0,1)-1)*(gestLength+lineWidth);
                    im(:,onsetX,:) = 0;
                    im(:,onsetX,3) = 255;
                    startX = (1:lineWidth) + (find(onsetTime == plotStart)-1)*(gestLength+lineWidth);
                    if isempty(startX)
                        startX = 1;
                    else
                        im(:,startX,:) = 0;
                    end
                    stopX = (1:lineWidth) + (find(onsetTime == plotEnd)-1)*(gestLength+lineWidth);
                    if isempty(stopX)
                        stopX = imL;
                    else
                        im(:,stopX,:) = 0;
                    end
                    fullIm = cat(1,fullIm,im);
                    % add space between gestures
                    im = uint8(255*ones(smallSpace,imL,3));
                    fullIm = cat(1,fullIm,im);
                end
                fullIm = fullIm(:,startX:stopX,:);
                figure(2)
                imshow(fullIm);
                axis equal
                imwrite(fullIm,['./realtime_figure_outputs/' f.name(1:end-4) '_' experiment(s).description '_onset_predictions.png'])
                drawnow
                
                % plot offset aligned predictions
                plotStart = -50;
                plotEnd = 50;
                gestWidth = 5;
                gestLength = 20;
                lineWidth = 1;
                smallSpace = 10;
                fullIm = [];
                for g = 2:numGest
                    imW = numGest*gestWidth + (numGest+1)*lineWidth;
                    imL = size(offsetAlignedPredictions,1)*gestLength + (size(offsetAlignedPredictions,1)+1)*lineWidth;
                    im = uint8(255*ones(imW,imL,3));
                    pred = offsetAlignedPredictions(:,g);
                    gndTruth = 100.*ones(size(pred));
                    gndTruth(offsetTime<0) = g+99;
                    for n = 1:length(pred)
                        if ~isnan(pred(n))
                            idx = pred(n) - 99;
                            cornerX = lineWidth + (lineWidth + gestWidth)*(idx-1)+1;
                            cornerY = lineWidth + (lineWidth + gestLength)*(n-1)+1;
                            im(cornerX:cornerX+gestWidth-1,cornerY:cornerY+gestLength-1,:) = 0;
                            if gndTruth(n) == pred(n)
                                im(cornerX:cornerX+gestWidth-1,cornerY:cornerY+gestLength-1,2) = 255;
                            else
                                im(cornerX:cornerX+gestWidth-1,cornerY:cornerY+gestLength-1,1) = 255;
                            end
                        end
                    end
                    im(1:lineWidth,:,:) = 0;
                    im(end-lineWidth+1:end,:,:) = 0;
                    im(:,1:lineWidth,:) = 0;
                    im(:,end-lineWidth+1:end,:) = 0;
                    
                    onsetX = (1:lineWidth) + (find(offsetTime>0,1)-2)*(gestLength+lineWidth);
                    im(:,onsetX,:) = 0;
                    im(:,onsetX,3) = 255;
                    startX = (1:lineWidth) + (find(offsetTime == plotStart)-1)*(gestLength+lineWidth);
                    if isempty(startX)
                        startX = 1;
                    else
                        im(:,startX,:) = 0;
                    end
                    stopX = (1:lineWidth) + (find(offsetTime == plotEnd)-1)*(gestLength+lineWidth);
                    if isempty(stopX)
                        stopX = imL;
                    else
                        im(:,stopX,:) = 0;
                    end
                    fullIm = cat(1,fullIm,im);
                    % add space between gestures
                    im = uint8(255*ones(smallSpace,imL,3));
                    fullIm = cat(1,fullIm,im);
                end
                fullIm = fullIm(:,startX:stopX,:);
                figure(3)
                imshow(fullIm);
                axis equal
                imwrite(fullIm,['./realtime_figure_outputs/' f.name(1:end-4) '_' experiment(s).description '_offset_predictions.png'])
                drawnow
                
                figure(4)
                set(gcf,'position',[355 112 1288 420])
                area(onsetTime,onsetAlignedStats)
                xlim([max([min(onsetTime),plotStart]) min([max(onsetTime),plotEnd])])
                hold on
                xline(0.1,':k','LineWidth',2)
                hold off
                axis off
                saveas(gcf,['./realtime_figure_outputs/' f.name(1:end-4) '_' experiment(s).description '_onsetStats.png'],'png')
                
                figure(5)
                set(gcf,'position',[355 112 1288 420])
                area(offsetTime,offsetAlignedStats)
                xlim([max([min(offsetTime),plotStart]) min([max(offsetTime),plotEnd])])
                hold on
                xline(0.1,':k','LineWidth',2)
                hold off
                axis off
                saveas(gcf,['./realtime_figure_outputs/' f.name(1:end-4) '_' experiment(s).description '_offsetStats.png'],'png')
                drawnow
            end
        end
    end
end