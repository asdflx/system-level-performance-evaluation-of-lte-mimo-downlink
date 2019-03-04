function [cdit] = codebook_csi_4tx(ri, pmi)
% Function:
%   - report the precoded 4tx-CSI by rank indicator (RI) and
%   precoding matrix indicator (PMI) to the transmitter
%
% InputArg(s):
%   - ri: the number of streams or layers transmitted to the user
%   - pmi: index of the preferred precoder in the codebook corresponding to
%   RI
%
% OutputArg(s):
%   - cdit: the precoded deficient CSI for channel reporting
%
% Restraints:
%   - only support 4-tx with 1 or 2 layers now (ri = 1 or 2)
%
% Comments:
%   - use the codebook defined in TS 36.211 Table 6.3.4.2.3-2
%   - MATLAB built-in function "lteCSICodebook" can be used instead
%
% Author & Date: Yang (i@snowztail.com) - 03 Mar 19

% PMI starts from zero but index start from 1
pmi = pmi + 1;
% number of transmit antennas
nTxs = 4;
% codebook size
nCsits = 16;
% identity vectors [u] to construct the precoding matrix [W]
idVector = zeros(nTxs, nCsits);
idVector(:, 1) = [1; -1; -1; -1];
idVector(:, 2) = [1; -1i; 1; 1i];
idVector(:, 3) = [1; 1; -1; 1];
idVector(:, 4) = [1; 1i; 1; -1i];
idVector(:, 5) = [1; (-1-1i)/sqrt(2); -1i; (1-1i)/sqrt(2)];
idVector(:, 6) = [1; (1-1i)/sqrt(2); 1i; (-1-1i)/sqrt(2)];
idVector(:, 7) = [1; (1+1i)/sqrt(2); -1i; (-1+1i)/sqrt(2)];
idVector(:, 8) = [1; (-1+1i)/sqrt(2); 1i; (1+1i)/sqrt(2)];
idVector(:, 9) = [1; -1; 1; 1];
idVector(:, 10) = [1; -1i; -1; -1i];
idVector(:, 11) = [1; 1; 1; -1];
idVector(:, 12) = [1; 1i; -1; 1i];
idVector(:, 13) = [1; -1; -1; 1];
idVector(:, 14) = [1; -1; 1; -1];
idVector(:, 15) = [1; 1; -1; -1];
idVector(:, 16) = [1; 1; 1; 1];
% the precoding matrix [W] containing the CSI to report
codeMatrix = cell(nCsits, 1);
for iCsit = 1: nCsits
    codeVector = idVector(:, iCsit);
    codeMatrix{iCsit} = eye(nTxs) - 2 * (codeVector * codeVector') / (codeVector' * codeVector);
end
% extract the precoded CSI (CDIT)
if ri == 1
    cdit = codeMatrix{pmi}(:, 1);
elseif ri == 2
    cdit = zeros(4, 2);
    % first layer
    cdit(:, 1) = codeMatrix{pmi}(:, 1);
    % second layer
    if ismember(pmi, [2 3 4 9 13 16])
        cdit(:, 2) = codeMatrix{pmi}(:, 2);
    elseif ismember(pmi, [7 8 11 12 14 15])
        cdit(:, 2) = codeMatrix{pmi}(:, 3);
    else
        cdit(:, 2) = codeMatrix{pmi}(:, 4);
    end
    cdit = cdit / sqrt(2);
else
    error('Sorry, the function currently supports 4-tx with 1 or 2 layers.');
end
end

