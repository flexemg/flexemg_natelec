close all
clear
clc

featEV = zeros(5,320);
hvEV = zeros(5,1000);
for s = 1:5
    load(['S' num2str(s) '_pca.mat'],'featPCAEV','hvPCAEV')
    featEV(s,:) = featPCAEV;
    hvEV(s,:) = hvPCAEV;
end
featEV = featEV';
hvEV = hvEV';

colors = colororder;


for s = 1:5
    figure(1)
    loglog(featEV(:,s),':','Color',colors(s,:),'LineWidth',3)
    hold on
    loglog(hvEV(:,s),'Color',colors(s,:),'LineWidth',3);
    
    figure(2)
    semilogx(cumsum(featEV(:,s)),':','Color',colors(s,:),'LineWidth',3)
    hold on
    semilogx(cumsum(hvEV(:,s)),'Color',colors(s,:),'LineWidth',3)
end

figure(1)
xlim([1 1000])
ylim([min(featEV(:)),1])
grid on

figure(2)
xlim([1 1000])
ylim([0 1])
grid on