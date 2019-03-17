function [sinr] = stream_sinr(nTxs, nRxs, nUsers, fading, pTx, pNoise)
% Function: 
%   - calculate the SINR of different streams of each user
%
% InputArg(s):
%   - nRxs, nTxs: number of receive and transmit antennas
%   - nUsers: number of users in one cell
%   - fading: spatially and temporally correlated Rayleigh flat fading 
%   - pTx: transmit power [Pt]
%   - pNoise: noise power [?]
%
% OutputArg(s):
%   - sinr: signal-to-interference-and-noise ratio of different layers
%
% Comments:
%   - 
%
% Author & Date: Yang (i@snowztail.com) - 16 Mar 19

sinr = zeros(nUsers, nRxs);
for iUser = 1: nUsers
    for iRx = 1: nRxs
        stream = fading{iUser}(iRx, :);
        streamInterf = setdiff(fading{iUser}, stream, 'rows');
        sinr(iUser, iRx) = pTx / nTxs * stream' * inv(pNoise * eye(nRxs) + pTx / nTxs * streamInterf(:)' * streamInterf(:)) * stream;
    end
end
end

