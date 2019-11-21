function [poseDegree, poseTime] = importRoninTextFile(RoninTextFile, angle, origin, scale)

% common setting to read text files
delimiter = ' ';
headerlinesIn = 1;
nanoSecondToSecond = 1000000000;


% import RoNIN text
textRoninData = importdata(RoninTextFile, delimiter, headerlinesIn);
poseTime = textRoninData.data(:,1).';
stateEsti_RoNIN = textRoninData.data(:,[2:3]).';
stateEsti_RoNIN(1,:) = (stateEsti_RoNIN(1,:) - stateEsti_RoNIN(1,1));
stateEsti_RoNIN(2,:) = (stateEsti_RoNIN(2,:) - stateEsti_RoNIN(2,1));


% rotate RoNIN trajectory (X-Y plane) only for pretty visualization
R = angle2rotmtx([0;0;(deg2rad(angle))]);
R = R(1:2,1:2);
stateEsti_RoNIN = R * stateEsti_RoNIN;


% convert coordinates (m) to lat/lon coordinates (deg)
stateEsti_RoNIN = stateEsti_RoNIN + origin(:,1);
[lon, lat] = mercatorToLatLon(stateEsti_RoNIN(1,:), stateEsti_RoNIN(2,:), scale);
poseDegree = [lat;lon];


end

