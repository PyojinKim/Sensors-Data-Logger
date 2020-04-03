function [RoninPolarIO] = convertRoninPolarCoordinate(RoninIO)

% new RoNIN polar coordinate with 1 Hz upsampling
numRonin = size(RoninIO,2);
RoninPolarIO(1).location = RoninIO(1).location;
RoninPolarIO(1).distance = 0.0;
RoninPolarIO(1).angle = 0.0;
for k = 2:numRonin
    
    % compute distance & angle
    deltaLocation = (RoninIO(k).location - RoninIO(k-1).location);
    distance = norm(deltaLocation);
    angle = atan2(deltaLocation(2), deltaLocation(1));
    
    
    % save each RoNIN distance & angle
    RoninPolarIO(k).location = RoninIO(k).location;
    RoninPolarIO(k).distance = distance;
    RoninPolarIO(k).angle = angle;
end


end

% % compute difference of angle for RoNIN accumulation nature
% roninPolarResult(1).deltaAngle = 0;
% for k = 2:numRonin
%     roninPolarResult(k).deltaAngle = roninPolarResult(k).angle - roninPolarResult(k-1).angle;
% end