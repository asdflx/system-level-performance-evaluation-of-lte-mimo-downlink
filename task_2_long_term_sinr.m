clear; close all;
%% Initialisation
% transmit power (in dBm) [Pt]
pTxDbm = 46;
pTx = db2pow(pTxDbm) / 1e3;
% noise variance (in dBm) [sigman^2]
pNoiseDbm = -174;
pNoise = db2pow(pNoiseDbm) / 1e3;
% number of users dropped in the center cell [K]
nUsers = 1e4;
% distance covered by the cell (in meters) [d]
dMin = 35; dMax = 250; 
% coordinate of neighbour base stations to produce interference [j]
nInterfs = 6;
bsInterf = 2 * dMax * exp(1i * 2 * pi / nInterfs * (1: nInterfs)');
% standard deviation of shadowing (in dB) [sigmas]
sdShadowing = 8;
% spatial correlation [t]
corSpatialConst = 0.5;
% number of drops (i.e. generate user distributions)
nDrops = 1e2;
% long-time SINR
sinr = zeros(nDrops, nUsers);
%% Channel model
%s generate user location randomly and uniformly (assume users don't move)
for iDrop = 1: nDrops
    % user distribution
    [dCenter, dInterf, ~, ~] = user_distribution(dMin, dMax, nUsers, nInterfs, corSpatialConst);
    % path loss and shadowing of center and interference base stations
    [psCenter, psInterf] = pathloss_shadowing(nUsers, nInterfs, dCenter, dInterf, sdShadowing);
    % long-term SINR of a drop
    sinr(iDrop, :) = (pTx ./ psCenter) ./ (pNoise + sum(pTx ./ psInterf));
end
sinrDb = pow2db(sinr);
rate = log2(1 + sinr);
%% Result plot
% CDF of long-term SINR
figure;
cdfplot(sinrDb(:));
grid on; grid minor;
legend('2D');
title('CDF of user long-term downlink SINR');
xlabel('Downlink SINR (dB)');
ylabel('CDF (%)');
xlim([-40 60]);
% CDF of user rate based on long-term SINR
figure;
cdfplot(rate(:));
grid on; grid minor;
legend('2D');
title('CDF of rate by user long-term downlink SINR');
xlabel('Average rate (bps/Hz)');
ylabel('CDF (%)');
