clear; close all;
%% Initialisation
% transmit power (in dBm) [Pt]
pTxDbm = 46;
pTx = db2pow(pTxDbm) / 1e3;
% noise variance (in dBm) [?n^2]
pNoiseDbm = -174;
pNoise = db2pow(pNoiseDbm) / 1e3;
% number of users dropped in the center cell [K]
nUsers = 10;    % nUsers = 10: 5: 50;
% distance covered by the cell (in meters) [d]
dMin = 35; dMax = 250; 
% coordinate of neighbour base stations to produce interference [j]
nInterfs = 6;
bsInterf = 2 * dMax * exp(1i * 2 * pi / nInterfs * (1: nInterfs));
% number of transmit antennas at each base station [nt]
nTxs = 4;
% number of receive antennas at each user [nr]
nRxs = 1;    % nRxs = 1: 2;
% standard deviation of shadowing (in dB) [?s]
stdShadowing = 8;
% time correlation [?]
corTime = 0.85;    % corTime = 0: 0.1: 1;
% spatial correlation [t]
corSpatialConst = 0.5;    %corSpatialConst = 0: 0.1: 1;
% number of sampling (i.e. times of parameters update)
nSamples = 1e3;
% number of drops (i.e. generate user distributions)
nDrops = 1e2;
% shadowing is a stochastic process (in dB) [S]
shadowingDb = zeros(nUsers, nSamples);
% transmit correlation matrix [Rt]
corSpatial = cell(nUsers, 1);
% temporally correlated Rayleigh flat fading channel [Htilde]
fadingTempCor = cell(nUsers, nSamples);
% spatially and temporally correlated Rayleigh flat fading channel [H]
fading = cell(nUsers, nSamples);
% long-time SINR
ltSinr = zeros(nUsers, nDrops);
%% System model
%s generate user location randomly and uniformly (assume users don't move)
for iDrop = 1: nDrops
    %% User distribution
    % distance between users and base station (in meters) [d]
    dCenter = randi([dMin, dMax], nUsers, 1);
    % angle (in radian) [?]
    phase = 2 * pi * rand(nUsers, 1);
    % coordinate of users
    user = dCenter .* exp(1i * phase);
    % distance between interference base station and user
    dInterf = abs(bsInterf - user);
    % transmit correlation matrix of base station i and user q [Rt]
    for iUser = 1: nUsers
        corTx = corSpatialConst * exp(1i * phase(iUser));
        corSpatial{iUser} = toeplitz([1, corTx, corTx ^ 2, corTx ^ 3]);
    end
    %% Path-loss, shadowing and fading
    % path loss model (in dB) [?0]
    pathLossDb = 128.1 + 37.6 * log10(dCenter / 1e3);
    % assume spatially and temporally correlated Rayleigh flat fading channel
    for iUser = 1: nUsers
        for iSample = 1: nSamples
            % temporally correlated channel [Htilde]
            if iSample == 1
                % channel initial state
                fadingTempCor{iUser, iSample} = randn(nRxs, nTxs);
            else
                % temporally correlated to the previous state
                fadingTempCor{iUser, iSample} = corTime * fadingTempCor{iUser, iSample - 1} + sqrt(1 - corTime ^ 2) * randn(nRxs, nTxs);
            end
            % shadowing model (in dB) [S]
            shadowingDb(iUser, iSample) = stdShadowing * randn;
            % spatially and temporally correlated channel [H]
            fading{iUser, iSample} = fadingTempCor{iUser, iSample} * corSpatial{iUser} ^ (1 / 2);
        end
    end
end
