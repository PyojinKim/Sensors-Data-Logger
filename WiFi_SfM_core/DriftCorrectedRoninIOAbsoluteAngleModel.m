function [RoninIOLocation] = DriftCorrectedRoninIOAbsoluteAngleModel(startLocation, rotation, scale, bias, RoninPolarDistance, RoninPolarAngle)

% compute drift-corrected Ronin IO location
numRoninIO = size(RoninPolarDistance,2);
RoninIOLocation = zeros(2,numRoninIO);
RoninIOLocation(:,1) = zeros(2,1);
for k = 2:numRoninIO
    
    % scale and bias for each segment
    s = scale(k);
    b = bias(k);
    
    % compute delta X and Y
    deltaX = s * RoninPolarDistance(k) * cos(RoninPolarAngle(k) + b);
    deltaY = s * RoninPolarDistance(k) * sin(RoninPolarAngle(k) + b);
    
    % accumulated Ronin IO location
    RoninIOLocation(:,k) = RoninIOLocation(:,k-1) + [deltaX; deltaY];
end


% rotation in 2D rigid body transformation
R = angle2rotmtx([0;0;rotation]);
R = R(1:2,1:2);
RoninIOLocation = R * RoninIOLocation;


% translation in 2D rigid body transformation
RoninIOLocation = RoninIOLocation + startLocation;


end

