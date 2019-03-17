clear; close all;
%% Initialisation
% transmit power (in dBm) [Pt]
pTxDbm = 46;
pTx = db2pow(pTxDbm) / 1e3;
% noise variance (in dBm) [?n^2]
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
% standard deviation of shadowing (in dB) [?s]
sdShadowing = 8;
% time correlation [?]
corTime = 0.85;
% spatial correlation [t]
corSpatialConst = 0.5;
% number of sampling (i.e. times of parameters update)
nSamples = 1e3;
% number of drops (i.e. generate user distributions)
nDrops = 1e1;
% fading from interference base stations
fadingInterf = cell(1, nInterfs);
fadingTemporalInterf = cell(1, nInterfs);
%% System model
%s generate user location randomly and uniformly (assume users don't move)
for iDrop = 1: nDrops
    % user distribution
    [dCenter, dInterf, corSpatial, corSpatialInterf] = user_distribution(dMin, dMax, nUsers, nInterfs, corSpatialConst);
    % initialise channel
    fadingTemporalPrev = cell(1, nUsers);
    fadingTemporalInterfPrev = cell(nInterfs, nUsers);
    for iSample = 1: nSamples
        % path loss and shadowing of center base station
        psCenterDb = 128.1 + 37.6 * log10(dCenter / 1e3) + sdShadowing * randn(1, nUsers);
        psCenter = db2pow(psCenterDb);
        % interference path loss and shadowing
        psInterfDb = 128.1 + 37.6 * log10(dInterf / 1e3) + sdShadowing * randn(nInterfs, nUsers);
        psInterf = db2pow(psInterfDb);
        % fading from center base station
        [fading, fadingTemporal] = fading_channel(nUsers, fadingTemporalPrev, corTime, corSpatial, nRxs, nTxs);
        % update channel status
        fadingTemporalPrev = fadingTemporal;
        % fading from interference base stations
        for iInterf = 1: nInterfs
            [fadingInterf{iInterf}, fadingTemporalInterf{iInterf}] = fading_channel(nUsers, fadingTemporalInterfPrev(iInterf, :), corTime, corSpatialInterf, nRxs, nTxs);
            % update channel status
            fadingTemporalInterfPrev(iInterf) = fadingTemporalInterf(iInterf);
        end
        % SINR of streams
%         [sinr] = stream_sinr(nTxs, nRxs, nUsers, fading, pTx, pNoise);
        % quantised precoding matrix
        [precoder] = quantised_precoding(nUsers, nRxs, fading, fadingInterf, psCenter, psInterf, pTx, pNoise);
    end
end
