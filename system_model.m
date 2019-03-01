clear; close all;
%% Initialisation
% transmit power (in dBm) [Pt]
pTxDbm = 46;
% noise variance (in dBm) [?n^2]
pNoiseDbm = -174;
% number of users dropped in the center cell [K]
nUsers = 10;    % nUsers = 10: 5: 50;
% distance covered by the cell (in meters) [d]
dMin = 35; dMax = 250; 
% number of neighbour base stations to produce interference [j]
nInterfBss = 6;
% number of transmit antennas at each base station [nt]
nTxs = 4;
% number of receive antennas at each user [nr]
nRxs = 1;    % nRxs = 1: 2;
% time correlation [?]
corTime = 0.85;    % corTime = 0: 0.1: 1;
% spatial correlation [t]
corSpatialConst = 0.5;    %corSpatialConst = 0: 0.1: 1;
% number of sampling (i.e. times of parameters update)
nSamples = 1e3;
% declare vars
% transmit correlation matrix [Rt]
corSpatial = cell(1, nUsers);
% temporally correlated Rayleigh flat fading channel [Htilde]
fadingTempCor = cell(nSamples, nUsers);
% spatially and temporally correlated Rayleigh flat fading channel [H]
fading = cell(nSamples, nUsers);
%% User distribution
%s generate user location randomly and uniformly (assume users don't move)
% distance between users and base station (in meters) [d]
d = randi([dMin, dMax], nUsers, 1);
% angle (in radian) [?]
phase = 2 * pi * rand(nUsers, 1);
% transmit correlation matrix of base station i and user q [Rt]
for iUser = 1: nUsers
    corTx = corSpatialConst * exp(1i * phase(iUser));
    corSpatial{iUser} = toeplitz([1, corTx, corTx ^ 2, corTx ^ 3]);
end
%% Path-loss and shadowing
% path loss model (in dB) [?0]
pathLossDb = 128.1 + 37.6 * log10(1e3 * d);
% standard deviation of shadowing (in dB) [?s]
stdShadowing = 8;
% shadowing model (in dB) [S]
shadowingDb = stdShadowing ^ 2 * randn(nUsers, 1);
%% Fading
% assume spatially and temporally correlated Rayleigh flat fading channel
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
