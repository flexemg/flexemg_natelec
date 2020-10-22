close all
clear

numSub = 10;
numGest = 12;
numTrial = 6;
hpp = 0.5;
fs = 2000;
numCh = 12;

snr = zeros(numSub,numGest,numTrial,numCh);
for s = 1:numSub
    filename = ['cometa/S' num2str(s) '_E1_A1'];
    load(filename);
    
    % noise level is rms of rest
    disp(['Calculating Cometa subject ' num2str(s) ' noise RMS'])
    firstOnset = find(diff(restimulus)>0,1);
    restFilt = highpass(emg(1:firstOnset,:),hpp,fs);
    restRMS = rms(restFilt(1:end-1000,:));
    
    for g = 1:numGest
        disp(['Calculating Cometa subject ' num2str(s) ' gesture ' num2str(g) ' RMS'])
        trialStarts = find(diff(restimulus)==g);
        trialEnds = find(diff(restimulus)==-g);
        if trialEnds(1) < trialStarts(1)
            trialEnds = trialEnds(2:end);
        end
        minLen = min([length(trialStarts) length(trialEnds)]);
        trialStarts = trialStarts(1:minLen);
        trialEnds = trialEnds(1:minLen);
        for t = 1:numTrial
            sigFilt = highpass(emg(trialStarts(t):trialEnds(t),:),hpp,fs);
            idx = round(length(sigFilt)/2) + (-499:500);
            sigRMS = rms(sigFilt(idx,:));
            snr(s,g,t,:) = sigRMS./restRMS;
        end
    end
end

% save('cometa_snr','snr');