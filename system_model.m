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
% coordinate of neighbour base stations to produce interference [j]
bsInterf = 2 * dMax * exp(1i * pi / 3 * (0: 5));
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
nDrops = 1e3;
% shadowing is a stochastic process (in dB) [S]
shadowingDb = zeros(nSamples, nUsers);
% transmit correlation matrix [Rt]
corSpatial = cell(1, nUsers);
% temporally correlated Rayleigh flat fading channel [Htilde]
fadingTempCor = cell(nSamples, nUsers);
% spatially and temporally correlated Rayleigh flat fading channel [H]
fading = cell(nSamples, nUsers);
% interference path loss and shadowing
interfDb = cell(nSamples, 1);
% long-time SINR
ltSinr = cell(nDrops, 1);
%% System model
%s generate user location randomly and uniformly (assume users don't move)
for iDrop = 1: nDrops
    %% User distribution
    % distance between users and base station (in meters) [d]
    d = randi([dMin, dMax], nUsers, 1);
    % angle (in radian) [?]
    phase = 2 * pi * rand(nUsers, 1);
    % coordinate of users
    user = d .* exp(1i * phase);
    % distance between interference base station and user
    dInterf = abs(bsInterf - user);
    % transmit correlation matrix of base station i and user q [Rt]
    for iUser = 1: nUsers
        corTx = corSpatialConst * exp(1i * phase(iUser));
        corSpatial{iUser} = toeplitz([1, corTx, corTx ^ 2, corTx ^ 3]);
    end
    %% Path-loss, shadowing and fading
    % path loss model (in dB) [?0]
    pathLossDb = 128.1 + 37.6 * log10(d / 1e3);
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
            % shadowing model (in dB) [S]
            shadowingDb(iSample, iUser) = stdShadowing * randn;
            % spatially and temporally correlated channel [H]
            fading{iSample, iUser} = fadingTempCor{iSample, iUser} * corSpatial{iUser} ^ (1 / 2);
        end
    end
    %% Long-term SINR
    for iSample = 1: nSamples
        % interference path loss and shadowing
        interfDb{iSample} = 128.1 + 37.6 * log10(dInterf / 1e3) + stdShadowing * randn(size(dInterf));
    end
    % average
    interfDb = mean(cat(3, interfDb{:}), 3);
    % long-term SINR of a drop
%     ltSinr(iDrop) = 
end

