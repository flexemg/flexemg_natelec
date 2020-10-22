function [onset] = get_onset_chgpts(session)
%     onset = find(diff(session.offlineLabel) > 0);
    onset = session.onsetUser/50;
end