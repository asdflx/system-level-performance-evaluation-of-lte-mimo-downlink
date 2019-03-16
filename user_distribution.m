function [dCenter, dInterf, corSpatial] = user_distribution(dMin, dMax, nUsers, nInterfs, corSpatialConst)
% Function: 
%   - Return coordinate and spatial correlation of users in one drop
%
% InputArg(s):
%   - dMin, dMax: min and max distances covered by the cell (in meters)
%   - nUsers: number of users in one cell
%   - nInterfs: number of interference base station
%   - corSpatialConst: spatial correlation [t]
%
% OutputArg(s):
%   - dCenter: distance to the center base station
%   - dInterf: distance to the interference base stations
%   - corSpatial: transmit correlation matrix of center station and user q [Rt]
%
% Comments:
%   - assume no intercell spatial correlation
%
% Author & Date: Yang (i@snowztail.com) - 16 Mar 19

% coordinate of interference base station
bsInterf = 2 * dMax * exp(1i * 2 * pi / nInterfs * (1: nInterfs)');
% transmit correlation matrix [Rt]
corSpatial = cell(1, nUsers);
% distance between users and base station (in meters) [d]
dCenter = randi([dMin, dMax], 1, nUsers);
% angle (in radian) [?]
phase = 2 * pi * rand(1, nUsers);
% coordinate of users
user = dCenter .* exp(1i * phase);
% distance between interference base station and user
dInterf = abs(bsInterf - user);
% transmit correlation matrix of center station and user q [Rt]
for iUser = 1: nUsers
    corTx = corSpatialConst * exp(1i * phase(iUser));
    corSpatial{iUser} = toeplitz([1, corTx, corTx ^ 2, corTx ^ 3]);
end
end

