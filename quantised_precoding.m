function [precoder] = quantised_precoding(nUsers, nRxs, fading, fadingInterf, psCenter, psInterf, pTx, pNoise)
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
%   - pTx: transmit power [Pt]
%   - pNoise: noise power [?]
%
% OutputArg(s):
%   - precoder: the best precoder (beamforming vector) to maximise the rate
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
precoder1 = cell(nPmis, 1);
precoder2 = cell(nPmis, 1);
%% Precoders Design
for iPmi = 0: nPmis - 1
    % single layer transmission
    [precoder1{iPmi + 1}] = codebook_csi_4tx(1, iPmi) * sqrt(pTx);
    % double layer transmission
    [precoder2{iPmi + 1}] = codebook_csi_4tx(2, iPmi) * sqrt(pTx / 2 * eye(2));
end
%% Maximise Rate by Precoder Selection
for iUser = 1: nUsers
    covIn1 = cell(nPmis, 1);
    covIn2 = cell(nPmis, 2);
    combiner1 = cell(nPmis, 1);
    combiner2 = cell(nPmis, 2);
    sinr1 = zeros(nPmis, 1);
    sinr2 = zeros(nPmis, 2);
    for iPmi = 0: nPmis - 1
        if nRxs == 1
            precoder = precoder1{iPmi + 1};
            % inter-cell interference
            interCell = cell(nInterfs, 1);
            for iInterf = 1: nInterfs
                precoderIc = precoder1{randi([1, nPmis])};
                interCell{iInterf} = 1 / psInterf(iInterf, iUser) * fadingInterf{iInterf}{iUser} * precoderIc * (fadingInterf{iInterf}{iUser} * precoderIc)';
            end
            interCell = sum(cat(3, interCell{:}), 3);
            % noise
            noise = pNoise * eye(nRxs);
            % covariance matrix of interference plus noise
            covIn1{iPmi + 1} = interCell + noise;
            % MMSE combiner
            combiner1{iPmi + 1} = 1 / sqrt(psCenter(iUser)) * (fading{iUser} * precoder)' / covIn1{iPmi + 1};
            % SINR of the current stream
            sinr1(iPmi + 1) = 1 / psCenter(iUser) * (fading{iUser} * precoder)' / covIn1{iPmi + 1} * fading{iUser} * precoder;
        elseif nRxs == 2
            % two available layers
            for iLayer = 1: nRxs
                % inter-stream interference
                precoder = precoder2{iPmi + 1}(:, iLayer);
                precoderIs = precoder2{iPmi + 1}(:, nRxs - iLayer + 1);
                interStream = 1 / psCenter(iUser) * fading{iUser} * precoderIs * (fading{iUser} * precoderIs)';
                % inter-cell interference
                interCell = cell(nInterfs, 1);
                for iInterf = 1: nInterfs
                    precoderIc = precoder2{randi([1, nPmis])};
                    interCell{iInterf} = 1 / psInterf(iInterf, iUser) * fadingInterf{iInterf}{iUser} * precoderIc * (fadingInterf{iInterf}{iUser} * precoderIc)';
                end
                interCell = sum(cat(3, interCell{:}), 3);
                % noise
                noise = pNoise * eye(nRxs);
                % covariance matrix of interference plus noise
                covIn2{iPmi + 1, iLayer} = interStream + interCell + noise;
                % MMSE combiner
                combiner2{iPmi + 1, iLayer} = 1 / sqrt(psCenter(iUser)) * (fading{iUser} * precoder)' / covIn2{iPmi + 1, iLayer};
                % SINR of the current stream
                sinr2(iPmi + 1, iLayer) = 1 / psCenter(iUser) * (fading{iUser} * precoder)' / covIn2{iPmi + 1, iLayer} * fading{iUser} * precoder;
            end
        end
    end
end
end
