close all
clear
clc

maxC = distinguishable_colors(13);
numC = 256;
allC = repmat(maxC,1,1,numC);
for i = 1:numC
    allC(:,:,i) = ones(size(maxC)) - (ones(size(maxC)) - allC(:,:,numC))*(i-1)/(numC-1);
end
allC = permute(allC, [2 3 1]);
allC = reshape(allC,3,13*numC);

for s = 2
    load(['S' num2str(s) '_pca.mat']);

    figure
    set(gcf,'Position',[1 1 2048 1184]);
    classes = unique(featLabel);
    numClass = length(classes);
    numComp = 10;
    for i = 1:numComp
        start = (min(featPCA(:,i)));
        stop = (max(featPCA(:,i)));
        step = (stop-start)/100;
        edges = start:step:stop;
        counts = zeros(numClass,length(edges)-1);
        for c = 1:numClass
            x = featPCA(featLabel==classes(c),i);
            y = histcounts(x,edges,'Normalization','probability');
            y = (round(y./max(y).*(numC-1)))+1 + (c-1)*numC;
            counts(c,:) = y;
        end
        subplot(numComp,2,2*i - 1)
        imagesc(counts)
        colormap(allC')
        axis tight
        xticks([])
        yticks([])
    end
    
    classes = unique(hvLabel);
    numClass = length(classes);
    numComp = 10;
    for i = 1:numComp
        start = (min(hvPCA(:,i)));
        stop = (max(hvPCA(:,i)));
        step = (stop-start)/100;
        edges = start:step:stop;
        counts = zeros(numClass,length(edges)-1);
        for c = 1:numClass
            x = hvPCA(hvLabel==classes(c),i);
            y = histcounts(x,edges,'Normalization','probability');
            y = (round(y./max(y).*(numC-1)))+1 + (c-1)*numC;
            counts(c,:) = y;
        end
        subplot(numComp,2,2*i)
        imagesc(counts)
        colormap(allC')
        axis tight
        xticks([])
        yticks([])
    end
    
    figure
    subplot(1,2,1)
    scatter(featPCA(:,1), featPCA(:,2),10,maxC(featLabel+1,:),'filled')
    axis off
    subplot(1,2,2)
    scatter(hvPCA(:,1), hvPCA(:,2),10,maxC(featLabel+1,:),'filled')
    axis off
    
    
end