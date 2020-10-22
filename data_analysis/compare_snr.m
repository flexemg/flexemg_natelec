close all
clear
clc

corder = colororder;
temp = corder(3,:);
corder(3,:) = corder(1,:);
corder(1,:) = temp;

flexemg = load('flexemg_snr.mat').snr;
cometa = load('cometa_snr.mat').snr;
capgmyo = load('capgmyo_snr.mat').snr;

histRange = -50:1:50;
histLim = [min(histRange) max(histRange)];

flexemg = 20*log10(flexemg);
flexemg([3 4 5 8 9 10],:,:,33:40) = nan;
flexemg = flexemg(:);
flexemg(isnan(flexemg)) = [];

cometa = 20*log10(cometa);
capgmyo = 20*log10(capgmyo);

cometa = cometa(:,:,:,1:8);

figure
set(gcf,'position',[500 500 900 350])
histogram(cometa,histRange,'Normalization','probability','FaceAlpha',0.3,'LineStyle','none','FaceColor',corder(1,:));
ylim([0 0.12])
hold on
histogram(capgmyo,histRange,'Normalization','probability','FaceAlpha',0.3,'LineStyle','none','FaceColor',corder(2,:));
histogram(flexemg,histRange,'Normalization','probability','FaceAlpha',0.3,'LineStyle','none','FaceColor',corder(3,:));
pd = fitdist(cometa(:),'Kernel');
plot(histRange,pdf(pd,histRange),'Color',corder(1,:))
pd = fitdist(capgmyo(:),'Kernel');
plot(histRange,pdf(pd,histRange),'Color',corder(2,:))
pd = fitdist(flexemg(:),'Kernel');
plot(histRange,pdf(pd,histRange),'Color',corder(3,:))
scatter(median(cometa(:)),0.9*max(ylim),100,corder(1,:),'V','filled')
scatter(median(capgmyo(:)),0.9*max(ylim),100,corder(2,:),'V','filled')
scatter(median(flexemg(:)),0.9*max(ylim),100,corder(3,:),'V','filled')

legend(['Cometa (n = ' num2str(numel(cometa)) ')'],['CapgMyo (n = ' num2str(numel(capgmyo)) ')'],['Our work (n = ' num2str(numel(flexemg)) ')'],'Location','northwest')
xlabel('SNR (dB)')
ylabel('PDF')
title('All channels and gestures')
xlim([-10 50])
