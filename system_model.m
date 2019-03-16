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
% number of transmit antennas at each base station [nt]
nTxs = 4;
% number of receive antennas at each user [nr]
nRxs = 1;    % nRxs = 1: 2;
% standard deviation of shadowing (in dB) [?s]
sdShadowing = 8;
% time correlation [?]
corTime = 0.85;    % corTime = 0: 0.1: 1;
% spatial correlation [t]
corSpatialConst = 0.5;    %corSpatialConst = 0: 0.1: 1;
% number of sampling (i.e. times of parameters update)
nSamples = 1e3;
% number of drops (i.e. generate user distributions)
nDrops = 1e1;
% temporally correlated Rayleigh flat fading channel [Htilde]
fadingTempCor = cell(nSamples, nUsers);
% spatially and temporally correlated Rayleigh flat fading channel [H]
fading = cell(nSamples, nUsers);
%% System model
%s generate user location randomly and uniformly (assume users don't move)
for iDrop = 1: nDrops
    % user distribution
    [dCenter, dInterf, corSpatial] = user_distribution(dMin, dMax, nUsers, nInterfs, corSpatialConst);
    % path-loss, shadowing and fading
    [centerPs, interfPs, fading] = channel_model(nSamples, nUsers, corTime, nRxs, nTxs, dCenter, dInterf, corSpatial, sdShadowing);
end
