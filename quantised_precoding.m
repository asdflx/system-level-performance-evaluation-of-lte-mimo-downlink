function [precoder] = quantised_precoding(nUsers, nRxs, fading, fadingInterf, centerPs, interfPs, pTx, pNoise)
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
%   - centerPs: path loss and shadowing of center base station
%   - interfPs: path loss and shadowing of interference base stations
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
nInterfs = size(interfPs, 1);
precoder1 = cell(nPmis, 1);
precoder2 = cell(nPmis, 1);
for iPmi = 0: nPmis - 1
    % single layer transmission
    [precoder1{iPmi + 1}] = codebook_csi_4tx(1, iPmi) * sqrt(pTx);
    % double layer transmission
    [precoder2{iPmi + 1}] = codebook_csi_4tx(2, iPmi) * sqrt(pTx / 2 * eye(2));
end
for iUser = 1: nUsers
    % covariance matrix of interference plus noise
    covIn = cell(nPmis, 1);
    for iPmi = 0: nPmis - 1
        if nRxs == 1
            % inter-cell interference only
            isInterf = fading{iUser} / centerPs(iUser) * precoder1{iPmi + 1};
            noise = pNoise * eye(nRxs);
            covIn{iPmi + 1} = isInterf + noise;
        elseif nRxs == 2
            % inter-stream interference plus inter-cell interference
            isInterf = 1 / centerPs(iUser) * fading{iUser} * precoder2{iPmi + 1}(:, 2) * (fading{iUser} * precoder2{iPmi + 1}(:, 2))';
            icInterf = cell(nInterfs, 1);
            for iInterf = 1: nInterfs
                icInterf{iInterf} = 1 / interfPs(iInterf, iUser) * fadingInterf{iInterf}{iUser} * precoder2{iPmi + 1} * (fadingInterf{iInterf}{iUser} * precoder2{iPmi + 1})';
            end
            icInterf = mean(cat(3, icInterf{:}), 3);
            noise = pNoise * eye(nRxs);
            covIn{iPmi + 1} = isInterf + icInterf + noise;
        end
        % MMSE combiner
%         combiner = 
    end
end
end
