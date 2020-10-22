close all
clear

corder = colororder;

flexemgDir = '../../dataset_hd/im_seed_0/';
files = dir([flexemgDir '*E1.mat']);
files = [files; dir([flexemgDir '*E7.mat'])];
signalLen = 4000;
numCh = 64;
numTrial = 5;
numGest = 12;
fs = 1000;
hpp = 0.5;
snr = zeros(length(files),numGest,numTrial,numCh);
% for s = 1:length(files)
for s = 3
    load([flexemgDir files(s).name])
    
    % noise level is rms of rest
    disp(['Calculating FlexEMG subject ' num2str(s) ' noise RMS'])
    restFilt = zeros(signalLen*numTrial,numCh);
    idx = 1:signalLen;
    for t = 1:numTrial
        x = highpass(emgHD(1,t).raw, hpp, fs);
        restFilt(idx,:) = x(3501:7500,:);
        idx = idx + signalLen;
    end
    restRMS = rms(restFilt);
    
    % snr is rms of signal divided by rms of rest
    for g = 1:numGest
        disp(['Calculating FlexEMG subject ' num2str(s) ' gesture ' num2str(g) ' RMS'])
        for t = 1:numTrial
            sigFilt = highpass(emgHD(g+1,t).raw, hpp, fs);
            sigRMS = rms(sigFilt(3501:7500,:));
            snr(s,g,t,:) = sigRMS./restRMS;
        end
    end
end

save('flexemg_snr','snr');