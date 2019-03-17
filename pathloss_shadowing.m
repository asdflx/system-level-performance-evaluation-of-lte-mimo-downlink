function [psCenter, psInterf] = pathloss_shadowing(nUsers, nInterfs, dCenter, dInterf, sdShadowing)
% Function: 
%   - calculate path loss and shadowing of center and interference base
%   stations
%
% InputArg(s):
%   - nUsers: number of users in one cell
%   - nInterfs: number of interference base station
%   - dCenter: distance to the center base station (in meters)
%   - dInterf: distances to the interference base stations (in meters)
%   - sdShadowing: standard deviation of shadowing
%
% OutputArg(s):
%   - psCenter: path loss and shadowing of center base station
%   - psInterf: path loss and shadowing of interference base stations
%
% Comments:
%   - shadowing is a stochastic process
%
% Author & Date: Yang (i@snowztail.com) - 17 Mar 19

% path loss and shadowing of center base station
psCenterDb = 128.1 + 37.6 * log10(dCenter / 1e3) + sdShadowing * randn(1, nUsers);
psCenter = db2pow(psCenterDb);
% path loss and shadowing of interference base stations
psInterfDb = 128.1 + 37.6 * log10(dInterf / 1e3) + sdShadowing * randn(nInterfs, nUsers);
psInterf = db2pow(psInterfDb);
end

