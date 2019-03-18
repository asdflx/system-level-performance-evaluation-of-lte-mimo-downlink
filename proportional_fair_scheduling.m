function [ltRate, userIndex] = proportional_fair_scheduling(nUsers, cqi, ltRate, tScale, qos)
% Function:
%   - perform proportional fair scheduling and return the long-term average
%   rate of users
%
% InputArg(s):
%   - nUsers: number of users in one cell
%   - cqi: the maximum achievable rate by the selected RI and PMI
%   - ltRate: previous long-term average rate
%   - tScale: scheduling time scale
%   - qos: quality of service of users
%
% OutputArg(s):
%   - ltRate: current long-term average rate after scheduling
%   - userIndex: user scheduled at the current instant
%
% Comments:
%   - equivalent to the rate-maximisation scheduler if the scheduling time
%   scale is large
%   - equivalent to the round-robin scheduler if the scheduling time scale
%   is small
%
% Author & Date: Yang (i@snowztail.com) - 17 Mar 19

% update the user that maximise the weighted rate function at every instant
[~, userIndex] = max(qos .* cqi ./ ltRate);
for iUser = 1: nUsers
    if iUser == userIndex
        % scheduled at current instant
        ltRate(iUser) = (1 - 1 / tScale) * ltRate(iUser) + 1 / tScale * cqi(iUser);
    else
        % unscheduled at current instant
        ltRate(iUser) = (1 - 1 / tScale) * ltRate(iUser);
    end
end
end

