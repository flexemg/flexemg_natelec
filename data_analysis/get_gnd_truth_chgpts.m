function [gndTruth] = get_gnd_truth_chgpts(session)
%     gndTruth = session.offlineLabel;
%     if length(gndTruth) >= length(session.prediction)
%         gndTruth = gndTruth(1:length(session.prediction));
%     else
%         gndTruth = [gndTruth; 100*ones(length(session.prediction) - length(gndTruth))];
%     end
    gndTruth = zeros(size(session.prediction));
    onset = get_onset_chgpts(session);
    offset = get_offset_chgpts(session);
    gndTruth(1:onset) = 100;
    gndTruth(onset+1:offset) = session.gesture;
    gndTruth(offset+1:end) = 100;
    if length(gndTruth) >= length(session.prediction)
        gndTruth = gndTruth(1:length(session.prediction));
    else
        gndTruth = [gndTruth; 100*ones(length(session.prediction) - length(gndTruth))];
    end
end