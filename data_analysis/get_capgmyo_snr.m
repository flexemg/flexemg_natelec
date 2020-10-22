close all
clear

numSub = 10;
numGest = 12;
numTrial = 10;
hpp = 0.5;
fs = 1000;
numCh = 128;

snr = zeros(numSub,numGest,numTrial,numCh);
for s = 1:numSub
    % noise level is rms of rest
    disp(['Calculating CapGMyo subject ' num2str(s) ' noise RMS'])
    restFilt = [];
    for g = 1:numGest
        filename = ['capgmyo/' num2str(s,'%03.f') '-' num2str(g,'%03.f')];
        load(filename);
        firstOnset = find(diff(gesture)>0,1);
        restWindow = 1:(firstOnset-1000);
        restFilt = [restFilt; highpass(data(restWindow,:),hpp,fs)];
    end
    restRMS = rms(restFilt);
    
    % snr is rms of signal divided by rms of rest
    for g = 1:numGest
        disp(['Calculating CapGMyo subject ' num2str(s) ' gesture ' num2str(g) ' RMS'])
        filename = ['capgmyo/' num2str(s,'%03.f') '-' num2str(g,'%03.f')];
        load(filename);
        trialStarts = find(diff(gesture)>0);
        trialEnds = find(diff(gesture)<0);
        if trialEnds(1) < trialStarts(1)
            trialEnds = trialEnds(2:end);
        end
        minLen = min([length(trialStarts) length(trialEnds)]);
        trialStarts = trialStarts(1:minLen);
        trialEnds = trialEnds(1:minLen);
        for t = 1:numTrial
            sigFilt = highpass(data(trialStarts(t):trialEnds(t),:),hpp,fs);
            idx = round(length(sigFilt)/2) + (-499:500);
            sigRMS = rms(sigFilt(idx,:));
            snr(s,g,t,:) = sigRMS./restRMS;
        end
    end
end

save('capgmyo_snr','snr');