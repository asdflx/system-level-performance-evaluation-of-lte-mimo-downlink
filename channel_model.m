function [centerPs, interfPs, fading] = channel_model(nSamples, nUsers, corTime, nRxs, nTxs, dCenter, dInterf, corSpatial, sdShadowing)
% Function: 
%   - Return path-loss, shadowing and fading at sampling points
%
% InputArg(s):
%   - nSamples: number of samples
%   - nUsers: number of users in one cell
%   - corTime: time correlation [?]
%   - nRxs, nTxs: number of receive and transmit antennas
%   - dCenter: distance to the center base station
%   - dInterf: distance to the interference base stations
%   - corSpatial: transmit correlation matrix of center station and user q [Rt]
%   - sdShadowing: standard deviation of shadowing
%
% OutputArg(s):
%   - centerPs: path loss and shadowing of center base station
%   - interfPs: interference path loss and shadowing
%   - fading: spatially and temporally correlated Rayleigh flat fading
%
% Comments:
%   - shadowing is a random process
%
% Author & Date: Yang (i@snowztail.com) - 16 Mar 19


% temporally correlated Rayleigh flat fading channel [Htilde]
fadingTempCor = cell(nSamples, nUsers);
% spatially and temporally correlated Rayleigh flat fading channel [H]
fading = cell(nSamples, nUsers);
% number of interference base station
nInterfs = size(dInterf, 1);
%% Path loss and shadowing
% path loss and shadowing of center base station
centerPsDb = 128.1 + 37.6 * log10(dCenter / 1e3) + sdShadowing * randn(1, nUsers);
centerPs = db2pow(centerPsDb);
% interference path loss and shadowing
interfPsDb = 128.1 + 37.6 * log10(dInterf / 1e3) + sdShadowing * randn(nInterfs, nUsers);
interfPs = db2pow(interfPsDb);
%% Fading
for iSample = 1: nSamples
    for iUser = 1: nUsers
        % temporally correlated channel [Htilde]
        if iSample == 1
            % channel initial state
            fadingTempCor{iSample, iUser} = randn(nRxs, nTxs);
        else
            % temporally correlated to the previous state
            fadingTempCor{iSample, iUser} = corTime * fadingTempCor{iSample - 1, iUser} + sqrt(1 - corTime ^ 2) * randn(nRxs, nTxs);
        end
        % spatially and temporally correlated channel [H]
        fading{iSample, iUser} = fadingTempCor{iSample, iUser} * corSpatial{iUser} ^ (1 / 2);
    end
end
end

