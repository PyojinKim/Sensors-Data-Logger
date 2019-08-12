function [q] = r2q( R )
% Project:   Patch-based illumination-variant DVO
% Function: r2q
%
% Description:
%   This function convert from rotation matrix to unit orientation quaternion
%
% Example:
%   OUTPUT:
%   quatVector: quaternion vector composed of [qw qx qy qz]
%
%   INPUT:
%   R = rotation matrix (3x3) defined as [inertial frame] = R * [body frame] (R = R_gb)
%
% NOTE:
%
% Author: Pyojin Kim
% Email: pjinkim1215@gmail.com
% Website:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% log:
% 2015-02-06: Complete
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

q1 = 0.5 * sqrt(1+R(1,1)+R(2,2)+R(3,3));
q2 = (1/(4*q1))*(R(3,2)-R(2,3));
q3 = (1/(4*q1))*(R(1,3)-R(3,1));
q4 = (1/(4*q1))*(R(2,1)-R(1,2));

q = [q1;q2;q3;q4];

end

