close all
clear
clc

corder = colororder;

flexemg = load('flexemg_snr.mat').snr;
cometa = load('cometa_snr.mat').snr;
capgmyo = load('capgmyo_snr.mat').snr;

flexemg = 20*log10(flexemg);
flexemg([3 4 5 8 9 10],:,:,33:40) = nan;

cometa = 20*log10(cometa);
cometa = cometa(:,:,:,1:8);

capgmyo = 20*log10(capgmyo);

% find gesture with the best SNR across all systems
flexGest = squeeze(nanmean(flexemg,1));
flexGest = squeeze(nanmean(flexGest,2));
flexGest = squeeze(nanmean(flexGest,2));

comGest = squeeze(nanmean(cometa,1));
comGest = squeeze(nanmean(comGest,2));
comGest = squeeze(nanmean(comGest,2));

capGest = squeeze(nanmean(capgmyo,1));
capGest = squeeze(nanmean(capGest,2));
capGest = squeeze(nanmean(capGest,2));

allGest = flexGest + capGest + comGest;

[~,bestGest] = max(allGest);

flexemg = squeeze(flexemg(:,bestGest,:,:));
[~,i] = maxk(flexemg(:),5);
[flexSub, flexTrial, flexChannel] = ind2sub(size(flexemg),i);

flexSub = flexSub(end);
flexTrial = flexTrial(end);
flexChannel = flexChannel(end);

if flexSub > 5
    flexSub = flexSub - 5;
    file = ['../../dataset_hd/im_seed_0/S' num2str(flexSub) 'E7.mat'];
else
    file = ['../../dataset_hd/im_seed_0/S' num2str(flexSub) 'E1.mat'];
end
load(file)
fs = 1000;
hpp = 0.5;
flexOn = highpass(emgHD(bestGest+1,flexTrial).raw(:,flexChannel),hpp,fs);
flexOn = flexOn(3501:7500);
flexOff = highpass(emgHD(1,1).raw(:,flexChannel),hpp,fs);
flexOff = flexOff(3501:7500);

subplot(1,2,1)
[pOff,fOff,cOff] = pwelch(flexOff,500,450,500,1000);
pOff = 10*log10(pOff);
p0 = pOff(1);
pOff = pOff - p0;
cOff = 10*log10(cOff);
plot(fOff,pOff,':','Color',corder(1,:))
hold on
[pOn,fOn,cOn] = pwelch(flexOn,500,450,500,1000);
pOn = 10*log10(pOn);
pOn = pOn - p0;
cOn = 10*log10(cOn);
plot(fOn,pOn,'Color',corder(1,:))

subplot(1,2,2)
plot(fOn,pOn-pOff,'Color',corder(1,:));
hold on

capgmyo = squeeze(capgmyo(:,bestGest,:,:));
fs = 1000;
hpp = 0.5;
[~,i] = max(capgmyo(:));
[capSub, capTrial, capChannel] = ind2sub(size(capgmyo),i);

file = ['./capgmyo/' num2str(capSub,'%03.f') '-' num2str(bestGest,'%03.f') '.mat'];
load(file)
firstOnset = find(diff(gesture)>0,1);
restWindow = 1:(firstOnset-1000);
capOff = highpass(data(restWindow,capChannel),hpp,fs);
capOff = capOff(1:4000);
trialStarts = find(diff(gesture)>0);
trialEnds = find(diff(gesture)<0);
if trialEnds(1) < trialStarts(1)
    trialEnds = trialEnds(2:end);
end
minLen = min([length(trialStarts) length(trialEnds)]);
trialStarts = trialStarts(1:minLen);
trialEnds = trialEnds(1:minLen);
capOn = highpass(data(trialStarts(capTrial):trialEnds(capTrial),capChannel),hpp,fs);
capOn = capOn(500:2500);

subplot(1,2,1)
[pOff,fOff,cOff] = pwelch(capOff,500,450,500,1000);
pOff = 10*log10(pOff);
p0 = pOff(1);
pOff = pOff - p0;
cOff = 10*log10(cOff);
plot(fOff,pOff,':','Color',corder(2,:))
[pOn,fOn,cOn] = pwelch(capOn,500,450,500,1000);
pOn = 10*log10(pOn);
pOn = pOn - p0;
cOn = 10*log10(cOn);
plot(fOn,pOn,'Color',corder(2,:))

subplot(1,2,2)
plot(fOn,pOn-pOff,'Color',corder(2,:))

cometa = squeeze(cometa(:,bestGest,:,:));
fs = 2000;
hpp = 0.5;
[~,i] = max(cometa(:));
[comSub, comTrial, comChannel] = ind2sub(size(cometa),i);
file = ['./cometa/S' num2str(comSub) '_E1_A1.mat'];
load(file);

firstOnset = find(diff(restimulus)>0,1);
comOff = highpass(emg(1:firstOnset,comChannel),hpp,fs);
comOff = comOff(1:4000);
    
trialStarts = find(diff(restimulus)==bestGest);
trialEnds = find(diff(restimulus)==-bestGest);
if trialEnds(1) < trialStarts(1)
    trialEnds = trialEnds(2:end);
end
minLen = min([length(trialStarts) length(trialEnds)]);
trialStarts = trialStarts(1:minLen);
trialEnds = trialEnds(1:minLen);


comOn = highpass(emg(trialStarts(comTrial):trialEnds(comTrial),comChannel),hpp,fs);
comOn = comOn(2000:6000);

subplot(1,2,1)
[pOff,fOff,cOff] = pwelch(comOff,1000,900,1000,2000);
pOff = 10*log10(pOff);
p0 = pOff(1);
pOff = pOff - p0;
cOff = 10*log10(cOff);
plot(fOff,pOff,':','Color',corder(3,:))
[pOn,fOn,cOn] = pwelch(comOn,1000,900,1000,2000);
pOn = 10*log10(pOn);
pOn = pOn - p0;
cOn = 10*log10(cOn);
plot(fOn,pOn,'Color',corder(3,:))
xlim([0 500])
subplot(1,2,2)
plot(fOn,pOn-pOff,'Color',corder(3,:))
xlim([0 500])
