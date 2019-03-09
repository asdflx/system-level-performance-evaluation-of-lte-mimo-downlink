clear; close all;
%% Initialisation
% transmit power (in dBm) [Pt]
pTxDbm = 46;
pTx = db2pow(pTxDbm) / 1e3;
% noise variance (in dBm) [?n^2]
pNoiseDbm = -174;
pNoise = db2pow(pNoiseDbm) / 1e3;
% number of users dropped in the center cell [K]
nUsers = 1e4;
% distance covered by the cell (in meters) [d]
dMin = 35; dMax = 250; 
% coordinate of neighbour base stations to produce interference [j]
nInterfs = 6;
bsInterf = 2 * dMax * exp(1i * 2 * pi / nInterfs * (1: nInterfs));
% standard deviation of shadowing (in dB) [?s]
stdShadowing = 8;
% number of drops (i.e. generate user distributions)
nDrops = 1e2;
% long-time SINR
ltSinr = zeros(nUsers, nDrops);
%% Channel model
%s generate user location randomly and uniformly (assume users don't move)
for iDrop = 1: nDrops
    %% User distribution
    % distance between users and center base station (in meters) [d]
    dCenter = randi([dMin, dMax], nUsers, 1);
    % angle (in radian) [?]
    phase = 2 * pi * rand(nUsers, 1);
    % coordinate of users
    user = dCenter .* exp(1i * phase);
    % distance between interference base station and user
    dInterf = abs(bsInterf - user);
    %% Path-loss, shadowing and Long-term SINR
    % path loss and shadowing of center base station
    centerPsDb = 128.1 + 37.6 * log10(dCenter / 1e3) + stdShadowing * randn(nUsers, 1);
    centerPs = db2pow(centerPsDb);
    % interference path loss and shadowing
    interfPsDb = 128.1 + 37.6 * log10(dInterf / 1e3) + stdShadowing * randn(nUsers, nInterfs);
    interfPs = db2pow(interfPsDb);
    % long-term SINR of a drop
    ltSinr(:, iDrop) = (pTx ./ centerPs) ./ (pNoise + sum(pTx ./ interfPs, 2));
end
ltSinrDb = pow2db(ltSinr);
%% Result plot: CDF of long-term SINR
figure;
cdfplot(ltSinrDb(:));
grid on; grid minor;
legend('2D');
title('CDF of user long-term downlink SINR');
xlabel('Downlink SINR (dB)');
ylabel('CDF (%)');
xlim([-40 60]);
