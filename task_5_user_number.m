clear; close all;
%% Initialisation
% transmit power (in dBm) [Pt]
pTxDbm = 46;
pTx = db2pow(pTxDbm) / 1e3;
% noise variance (in dBm) [sigman^2]
pNoiseDbm = -174;
pNoise = db2pow(pNoiseDbm) / 1e3;
% number of users dropped in the center cell [K]
nUsers = 10: 10: 50;
% distance covered by the cell (in meters) [d]
dMin = 35; dMax = 250;
% coordinate of neighbour base stations to produce interference [j]
nInterfs = 6;
% number of transmit antennas at each base station [nt]
nTxs = 4;
% number of receive antennas at each user [nr]
nRxs = 1;
% standard deviation of shadowing (in dB) [sigmas]
sdShadowing = 8;
% time correlation [epsilon]
corTime = 0.85;
% spatial correlation [t]
corSpatialConst = 0.5;
% drop duration (large enough to avoid transient state in the end) [T]
tDrop = 1e3;
% scheduling time scale [tc]
tScale = 1e1;
% number of drops (i.e. generate user distributions) [X]
nDrops = 1e2;
% user average rate
rate = cell(1, length(nUsers));
%% System model
for iUser = 1: length(nUsers)
    % quality of service (assume equal)
    qos = ones(1, nUsers(iUser));
    rate{iUser} = zeros(nDrops, nUsers(iUser));
    %s generate user location randomly and uniformly (assume users don't move)
    for iDrop = 1: nDrops
        fadingInterf = cell(nInterfs, nUsers(iUser));
        % model temporal correlation
        fadingTemporal = cell(1, nUsers(iUser));
        fadingInterfTemporal = cell(nInterfs, nUsers(iUser));
        % initialise scheduled user index and the average rate
        userIndex = 0;
        avgRate = zeros(1, nUsers(iUser)) + eps;
        instRate = zeros(tDrop, nUsers(iUser));
        % user distribution
        [dCenter, dInterf, corSpatial, corSpatialInterf] = user_distribution(dMin, dMax, nUsers(iUser), nInterfs, corSpatialConst);
        for iSample = 1: tDrop
            % path loss and shadowing of center and interference base stations
            [psCenter, psInterf] = pathloss_shadowing(nUsers(iUser), nInterfs, dCenter, dInterf, sdShadowing);
            % fading of center base station
            [fading, fadingTemporal] = fading_channel(nUsers(iUser), fadingTemporal, corTime, corSpatial, nRxs, nTxs);
            % fading of interference base stations
            for iInterf = 1: nInterfs
                [fadingInterf(iInterf, :), fadingInterfTemporal(iInterf, :)] = fading_channel(nUsers(iUser), fadingInterfTemporal(iInterf, :), corTime, corSpatialInterf, nRxs, nTxs);
            end
            % quantised precoding matrix
            [ri, pmi, cqi] = quantised_precoding(nUsers(iUser), nRxs, fading, fadingInterf, psCenter, psInterf, pTx, pNoise);
            % proportional fair scheduling
            [avgRate, userIndex] = proportional_fair_scheduling(nUsers(iUser), cqi, avgRate, tScale, qos, iSample, userIndex);
            instRate(iSample, userIndex) = cqi(userIndex);
        end
        rate{iUser}(iDrop, :) = mean(instRate);
    end
    rate{iUser} = rate{iUser}(:);
end
%% Result plot: CDF of user average rate
figure;
legendString = cell(length(nUsers), 1);
for iUser = 1: length(nUsers)
    cdfplot(rate{iUser});
    legendString{iUser} = sprintf('K = %d', nUsers(iUser));
    hold on;
end
hold off;
grid on; grid minor;
legend(legendString, 'location', 'southeast');
title('Influence of user number on user average rate');
xlabel('Average rate (bps/Hz)');
ylabel('CDF (%)');
