function [eulerAngle]= rotmtx2angle( R )
% Project:   Patch-based Illumination invariant Visual Odometry (PIVO)
% Function: rotmtx2angle
%
% Description:
%   This function return the euler angle along x,y and z direction
%   from rotation matrix to [phi;theta;psi] angle defined as ZYX sequence
%
% Example:
%   OUTPUT:
%   eulerAngle: angle vector composed of [phi;theta;psi]
%               phi = Rotation angle along x direction in radians
%               theta = Rotation angle along y direction in radians
%               psi = Rotation angle along z direction in radians
%
%   INPUT:
%   R = rotation matrix (3x3) defined as [body frame] = R * [inertial frame] (R = R_bg)
%
% NOTE:
%
% Author: Pyojin Kim
% Email: pjinkim1215@gmail.com
% Website:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% log:
% 2017-02-06: Complete
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

% change rotMtxBody / [Inertial frame] = rotMtxBody * [Body frame]
rotMtxBody = R.';

phi=atan2( rotMtxBody(3,2) , rotMtxBody(3,3) );
theta=asin( -rotMtxBody(3,1) );
psi=atan2( rotMtxBody(2,1) , rotMtxBody(1,1) );

eulerAngle = [phi;theta;psi];

end


