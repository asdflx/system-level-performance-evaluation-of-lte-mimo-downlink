clear; close all;
%% Initialisation
% transmit power (in dBm) [Pt]
pTxDbm = 46;
pTx = db2pow(pTxDbm) / 1e3;
% noise variance (in dBm) [sigman^2]
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
nRxs = 1: 2;
% standard deviation of shadowing (in dB) [sigmas]
sdShadowing = 8;
% time correlation [epsilon]
corTime = 0.85;
% spatial correlation [t]
corSpatialConst = 0.5;
% drop duration (large enough to avoid transient state in the end) [T]
tDrop = 1e2;
% scheduling time scale [tc]
tScale = 1e2;
% number of drops (i.e. generate user distributions) [X]
nDrops = 1e3;
% quality of service (assume equal)
qos = ones(1, nUsers);
% user average rate
rate = cell(1, length(nRxs));
%% System model
for iRx = 1: length(nRxs)
    rate{iRx} = zeros(nDrops, nUsers);
    %s generate user location randomly and uniformly (assume users don't move)
    for iDrop = 1: nDrops
        fadingInterf = cell(nInterfs, nUsers);
        % model temporal correlation
        fadingTemporal = cell(1, nUsers);
        fadingInterfTemporal = cell(nInterfs, nUsers);
        % initialise scheduled user index and the average rate
        userIndex = 0;
        ltRate = zeros(1, nUsers) + eps;
        instRate = zeros(tDrop, nUsers);
        % user distribution
        [dCenter, dInterf, corSpatial, corSpatialInterf] = user_distribution(dMin, dMax, nUsers, nInterfs, corSpatialConst);
        for iSample = 1: tDrop
            % path loss and shadowing of center and interference base stations
            [psCenter, psInterf] = pathloss_shadowing(nUsers, nInterfs, dCenter, dInterf, sdShadowing);
            % fading of center base station
            [fading, fadingTemporal] = fading_channel(nUsers, fadingTemporal, corTime, corSpatial, nRxs(iRx), nTxs);
            % fading of interference base stations
            for iInterf = 1: nInterfs
                [fadingInterf(iInterf, :), fadingInterfTemporal(iInterf, :)] = fading_channel(nUsers, fadingInterfTemporal(iInterf, :), corTime, corSpatialInterf, nRxs(iRx), nTxs);
            end
            % quantised precoding matrix
            [ri, pmi, cqi] = linear_precoding(nUsers, nRxs(iRx), fading, fadingInterf, psCenter, psInterf, pTx, pNoise);
            % proportional fair scheduling
            [ltRate, userIndex] = proportional_fair_scheduling(nUsers, cqi, ltRate, tScale, qos);
            instRate(iSample, userIndex) = cqi(userIndex);
        end
        rate{iRx}(iDrop, :) = mean(instRate);
    end
    rate{iRx} = rate{iRx}(:);
end
%% Result plot: CDF of user average rate
figure;
legendString = cell(length(nRxs), 1);
for iRx = 1: length(nRxs)
    cdfplot(rate{iRx});
    legendString{iRx} = sprintf('n_r = %d', nRxs(iRx));
    hold on;
end
hold off;
grid on; grid minor;
legend(legendString, 'location', 'southeast');
title('Influence of number of receive antennas on user average rate');
xlabel('Average rate (bps/Hz)');
ylabel('CDF (%)');