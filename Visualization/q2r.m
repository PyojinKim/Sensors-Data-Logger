function R = q2r( q )
% Project:   Patch-based illumination-variant DVO
% Function: q2r
%
% Description:
%   This function convert from unit orientation quaternion to rotation matrix
%
% Example:
%   OUTPUT:
%   R = rotation matrix (3x3) defined as [inertial frame] = R * [body frame] (R = R_gb)
%
%   INPUT:
%   quatVector: quaternion vector composed of [qw qx qy qz]
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

% quaternion to dcm
q = q/norm(q);

a = q(1);
b = q(2);
c = q(3);
d = q(4);
R=[ a*a+b*b-c*c-d*d,     2*(b*c-a*d),     2*(b*d+a*c);
    2*(b*c+a*d), a*a-b*b+c*c-d*d,     2*(c*d-a*b);
    2*(b*d-a*c),     2*(c*d+a*b), a*a-b*b-c*c+d*d; ];

end