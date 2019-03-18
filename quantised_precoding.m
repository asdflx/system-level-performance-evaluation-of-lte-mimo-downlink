function [ri, pmi, cqi] = quantised_precoding(nUsers, nRxs, fading, fadingInterf, psCenter, psInterf, pTx, pNoise)
% Function:
%   - return the best precoder (beamforming vector) from the codebook based
%   on the channel state and the number of available layers
%
% InputArg(s):
%   - nUsers: number of users in one cell
%   - nRxs: number of receive antennas, denoting the number of available
%   streams or layers transmitted to the user
%   - fading: spatially and temporally correlated Rayleigh flat fading
%   - fadingInterf: fading from interference base stations
%   - psCenter: path loss and shadowing of center base station
%   - psInterf: path loss and shadowing of interference base stations
%   - pTx: transmit power
%   - pNoise: noise power
%
% OutputArg(s):
%   - ri: the number of streams or layers transmitted to the user
%   - pmi: index of the preferred precoder in the codebook corresponding to
%   RI
%   - cqi: the maximum achievable rate by the selected RI and PMI
%
% Restraints:
%   - only support 4-tx with 1 or 2 layers now (ri = 1 or 2)
%
% Comments:
%   - in 2-rx cases, RI chosen to maximise the rate can be either 1 or 2
%
% Author & Date: Yang (i@snowztail.com) - 16 Mar 19

nPmis = 16;
nInterfs = size(psInterf, 1);
precoderSingle = cell(nPmis, 1);
precoderDouble = cell(nPmis, 1);
ri = zeros(1, nUsers);
pmi = zeros(1, nUsers);
cqi = zeros(1, nUsers);
%% Precoder Design
for iPmi = 0: nPmis - 1
    % single layer transmission
    [precoderSingle{iPmi + 1}] = codebook_csi_4tx(1, iPmi) * sqrt(pTx);
    % double layer transmission
    [precoderDouble{iPmi + 1}] = codebook_csi_4tx(2, iPmi) * sqrt(pTx / 2 * eye(2));
end
%% Precoder Selection
for iUser = 1: nUsers
    rate = zeros(nPmis, 2);
    for iPmi = 0: nPmis - 1
        precoder = precoderSingle{iPmi + 1};
        % inter-cell interference
        interCell = cell(nInterfs, 1);
        for iInterf = 1: nInterfs
            precoderIc = precoderSingle{randi([1, nPmis])};
            interCell{iInterf} = 1 / psInterf(iInterf, iUser) * fadingInterf{iInterf, iUser} * precoderIc * (fadingInterf{iInterf, iUser} * precoderIc)';
        end
        interCell = sum(cat(3, interCell{:}), 3);
        % noise
        noise = pNoise * eye(nRxs);
        % covariance matrix of interference plus noise
        covIn = interCell + noise;
        % SINR of the current stream
        sinr = 1 / psCenter(iUser) * (fading{iUser} * precoder)' / covIn * fading{iUser} * precoder;
        % remove imaginary part
        sinr = real(sinr);
        % achievable rate
        rate(iPmi + 1, 1) = log2(1 + sinr);
        if nRxs == 2
            % two available layers
            for iLayer = 1: nRxs
                % inter-stream interference
                precoder = precoderDouble{iPmi + 1}(:, iLayer);
                precoderIs = precoderDouble{iPmi + 1}(:, nRxs - iLayer + 1);
                interStream = 1 / psCenter(iUser) * fading{iUser} * precoderIs * (fading{iUser} * precoderIs)';
                % inter-cell interference
                interCell = cell(nInterfs, 1);
                for iInterf = 1: nInterfs
                    precoderIc = precoderDouble{randi([1, nPmis])};
                    interCell{iInterf} = 1 / psInterf(iInterf, iUser) * fadingInterf{iInterf, iUser} * precoderIc * (fadingInterf{iInterf, iUser} * precoderIc)';
                end
                interCell = sum(cat(3, interCell{:}), 3);
                % noise
                noise = pNoise * eye(nRxs);
                % covariance matrix of interference plus noise
                covIn = interStream + interCell + noise;
                % SINR of the current stream
                sinr = 1 / psCenter(iUser) * (fading{iUser} * precoder)' / covIn * fading{iUser} * precoder;
                % remove imaginary part
                sinr = real(sinr);
                % achievable rate
                rate(iPmi + 1, 2) = rate(iPmi + 1, 2) + log2(1 + sinr);
            end
        end
    end
    % optimum single-layer and double-layer precoder
    [rate, pmiIndex] = max(rate);
    % select transmit mode (1 or 2 layers) to maximise rate
    [cqi(iUser), ri(iUser)] = max(rate);
    pmi(iUser) = pmiIndex(ri(iUser));
end
end
