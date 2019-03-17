function [fading, fadingTemporal] = fading_channel(nUsers, fadingTemporalPrev, corTime, corSpatial, nRxs, nTxs)
% Function: 
%   - generate spatially and temporally correlated Rayleigh flat fading
%   channels at certain time instant for multiple users
%
% InputArg(s):
%   - nUsers: number of users in one cell
%   - fadingTemporalPrev: temporally correlated (spatially uncorrelated) 
%   channel in the previous state
%   - corTime: time correlation
%   - corSpatial: transmit correlation matrix of center station and user
%   - nRxs, nTxs: number of receive and transmit antennas
%
% OutputArg(s):
%   - fading: spatially and temporally correlated Rayleigh flat fading
%   - fadingTemporal: temporally correlated (spatially uncorrelated) 
%   channel
%
% Comments:
%   - the spatial and temporal correlations should be separated
%
% Author & Date: Yang (i@snowztail.com) - 16 Mar 19

fading = cell(1, nUsers);
fadingTemporal = cell(1, nUsers);
for iUser = 1: nUsers
    if isempty(fadingTemporalPrev{iUser})
        % initial channel state
        fadingTemporal{iUser} = randn(nRxs, nTxs);
    else
        % temporally correlated to the previous state
        fadingTemporal{iUser} = corTime * fadingTemporalPrev{iUser} + sqrt(1 - corTime ^ 2) * randn(nRxs, nTxs);
    end
    % spatially and temporally correlated channel
    fading{iUser} = fadingTemporal{iUser} * corSpatial{iUser} ^ (1 / 2);
end
end

