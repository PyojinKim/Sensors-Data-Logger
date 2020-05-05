function [h] = plot_sensor_frame(R_gb, p_gb, camScale)
% Project:    RoNIN Alignment with Multiple Sensors
% Function:  plot_sensor_frame
%
% Description:
%   draw sensor (body) frame of smartphone dataset
%
% Example:
%   OUTPUT:
%   h: plot handler
%
%
%   INPUT:
%   R_gb: rotation matrix of sensor frame (T_gc(1:3,1:3))
%   p_gb: position vector of sensor frame (T_gc(1:3,4))
%   camScale: scale of sensor frame
%
%
%
% NOTE:
%   Copyright 2019 GrUVi Lab @ Simon Fraser University
%
% Author: Pyojin Kim
% Email: pjinkim1215@gmail.com
% Website: http://pyojinkim.me/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% log:
% 2019-09-20: Complete
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

% rotate the sensor frame from {B} to {G}
camFrame = camScale * ((960/2) / 1000) * eye(3);
camFrame = R_gb * camFrame;

% translate sensor frame
camFrame = camFrame + [p_gb(1:3) p_gb(1:3) p_gb(1:3)];

% draw the sensor (body) frame
line([camFrame(1,1) p_gb(1)],[camFrame(2,1) p_gb(2)],[camFrame(3,1) p_gb(3)],'Color','r','LineWidth',2);
line([camFrame(1,2) p_gb(1)],[camFrame(2,2) p_gb(2)],[camFrame(3,2) p_gb(3)],'Color','g','LineWidth',2);
h = line([camFrame(1,3) p_gb(1)],[camFrame(2,3) p_gb(2)],[camFrame(3,3) p_gb(3)],'Color','b','LineWidth',2);


end