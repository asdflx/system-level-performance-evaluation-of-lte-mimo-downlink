clear; close all;
%% Initialisation
% transmit power (in dBm) [Pt]
pTxDbm = 46;
pTx = db2pow(pTxDbm) / 1e3;
% noise variance (in dBm) [sigma_n^2]
pNoiseDbm = -174;
pNoise = db2pow(pNoiseDbm) / 1e3;
% number of users dropped in the center cell [K]
nUsers = 10;
% distance covered by the cell (in meters) [d]
dMin = 35; dMax = 250; 
% coordinate of neighbour base stations to produce interference [j]
nInterfs = 6;
% number of transmit antennas at each base station [nt]
nTxs = 4;
% number of receive antennas at each user [nr]
nRxs = 2;
% standard deviation of shadowing (in dB) [sigma_s]
sdShadowing = 8;
% time correlation [epsilon]
corTime = 0.85;
% spatial correlation [t]
corSpatialConst = 0.5;
% number of sampling (i.e. times of parameters update)
nSamples = 1e3;
% number of drops (i.e. generate user distributions)
nDrops = 1e1;
%% System model
%s generate user location randomly and uniformly (assume users don't move)
for iDrop = 1: nDrops
    fadingInterf = cell(nInterfs, nUsers);
    % model temporal correlation
    fadingTemporal = cell(1, nUsers);
    fadingInterfTemporal = cell(nInterfs, nUsers);
    % user distribution
    [dCenter, dInterf, corSpatial, corSpatialInterf] = user_distribution(dMin, dMax, nUsers, nInterfs, corSpatialConst);
    for iSample = 1: nSamples
        % path loss and shadowing of center and interference base stations
        [psCenter, psInterf] = pathloss_shadowing(nUsers, nInterfs, dCenter, dInterf, sdShadowing);
        % fading of center base station
        [fading, fadingTemporal] = fading_channel(nUsers, fadingTemporal, corTime, corSpatial, nRxs, nTxs);
        % fading of interference base stations
        for iInterf = 1: nInterfs
            [fadingInterf(iInterf, :), fadingInterfTemporal(iInterf, :)] = fading_channel(nUsers, fadingInterfTemporal(iInterf, :), corTime, corSpatialInterf, nRxs, nTxs);
        end
        % quantised precoding matrix
        [ri, pmi, cqi] = quantised_precoding(nUsers, nRxs, fading, fadingInterf, psCenter, psInterf, pTx, pNoise);
    end
end
