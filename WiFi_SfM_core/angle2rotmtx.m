function [ R ] = angle2rotmtx(eulerAngle)
% Project:   Patch-based Illumination invariant Visual Odometry (PIVO)
% Function: angle2rotmtx
%
% Description:
%   This function return the rotation matrix rotMtx
%   [Body frame] = rotMtx * [Inertial frame]
%   from [phi;theta;psi] angle defined as ZYX sequence to rotation matrix
%
% Example:
%   OUTPUT:
%   R = rotation matrix (3x3) defined as [body frame] = R * [inertial frame] (R = R_bg)
%
%   INPUT:
%   eulerAngle: angle vector composed of [phi;theta;psi]
%               phi = Rotation angle along x direction in radians
%               theta = Rotation angle along y direction in radians
%               psi = Rotation angle along z direction in radians
%
% NOTE:
%
% Author: Pyojin Kim
% Email: pjinkim1215@gmail.com
% Website:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% log:
% 2016-08-20:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

% assign roll, pitch, yaw values
phi = eulerAngle(1);
theta = eulerAngle(2);
psi = eulerAngle(3);

R_x = [1 0 0;0 cos(phi) -sin(phi);0 sin(phi) cos(phi)];

R_y = [cos(theta) 0 sin(theta);0 1 0;-sin(theta) 0 cos(theta)];

R_z = [cos(psi) -sin(psi) 0; sin(psi) cos(psi) 0; 0 0 1];

rotMtxBody = [R_z * R_y * R_x]; % [Inertial frame] = rotMtxBody * [Body frame]

R = rotMtxBody.'; % [Body frame] = rotMtx * [Inertial frame]

end

