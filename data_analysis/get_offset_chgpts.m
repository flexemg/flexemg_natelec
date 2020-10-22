function [offset] = get_offset_chgpts(session)
%     offset = find(diff(session.offlineLabel) < 0);
    offset = session.offsetUser/50;
end