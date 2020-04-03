function [roninResult] = parseRoninTextFile(roninTextFile, dataInterval, dataYawRotation)

% common setting to read text files
delimiter = ' ';
headerlinesIn = 0;


% open RoNIN text file
textRoninData = importdata(roninTextFile, delimiter, headerlinesIn);
roninTime = textRoninData(:,1).';
roninData = textRoninData(:,[2:3]).';
roninTime = roninTime(1:dataInterval:end);
roninData = roninData(:,1:dataInterval:end);


% rotate RoNIN 2D trajectory with yaw angle
R = angle2rotmtx([0;0;(deg2rad(dataYawRotation))]);
roninData = R(1:2,1:2) * roninData;


% construct RoNIN trajectory results
numRonin = size(roninData,2);
roninResult = struct('timestamp', cell(1,numRonin), 'location', cell(1,numRonin));
for k = 1:numRonin
    
    % save each RoNIN location
    roninResult(k).timestamp = roninTime(k);
    roninResult(k).location = roninData(:,k);
end


end
