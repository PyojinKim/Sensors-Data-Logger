function [poseDegree, poseTime] = importTangoTextFile(tangoTextFile, angle, origin, scale)

% common setting to read text files
delimiter = ' ';
headerlinesIn = 1;
nanoSecondToSecond = 1000000000;


% import Tango text
textTangoPoseData = importdata(tangoTextFile, delimiter, headerlinesIn);
poseTime = textTangoPoseData.data(:,1).';
poseTime = poseTime ./ nanoSecondToSecond;
poseRotation = textTangoPoseData.data(:,[5 2 3 4]).';
poseTranslation = textTangoPoseData.data(:,[6 7 8]).';


% Tango sensor pose with various 6-DoF sensor pose representations
numPose = size(poseRotation,2);
R_gb_Tango = zeros(3,3,numPose);
T_gb_Tango = cell(1,numPose);
stateEsti_Tango = zeros(6,numPose);
for k = 1:numPose
    
    % rigid body transformation matrix (4x4) (rotation matrix SO(3) from quaternion)
    R_gb_Tango(:,:,k) = q2r(poseRotation(:,k));
    T_gb_Tango{k} = [R_gb_Tango(:,:,k), poseTranslation(:,k); [0, 0, 0, 1]];
    
    % state vector and rotation matrix
    stateEsti_Tango(1:3,k) = T_gb_Tango{k}(1:3,4);
    [yaw, pitch, roll] = dcm2angle(R_gb_Tango(:,:,k));
    stateEsti_Tango(4:6,k) = [roll; pitch; yaw];
end


% rotate Tango trajectory (X-Y plane) only for pretty visualization
R = angle2rotmtx([0;0;(deg2rad(angle))]);
stateEsti_Tango(1:3,:) = R * stateEsti_Tango(1:3,:);


% convert coordinates (m) to lat/lon coordinates (deg)
stateEsti_Tango(1:2,:) = stateEsti_Tango(1:2,:) + origin(:,1);
[lon, lat] = mercatorToLatLon(stateEsti_Tango(1,:), stateEsti_Tango(2,:), scale);
poseDegree = [lat;lon];


end

