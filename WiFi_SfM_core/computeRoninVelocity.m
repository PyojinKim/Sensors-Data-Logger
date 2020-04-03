function [roninResult] = computeRoninVelocity(roninResult)

% compute velocity from RoNIN location, time
roninTime = [roninResult(:).timestamp];
roninLocation = [roninResult(:).location];

timeDifference = [diff(roninTime); diff(roninTime)];
locationDifference = diff(roninLocation,1,2);

roninVelocity = locationDifference ./ timeDifference;
roninVelocity = [zeros(2,1), roninVelocity];


% append RoNIN velocity and speed results
numRonin = size(roninResult,2);
for k = 1:numRonin
    
    % save each RoNIN velocity and speed
    roninResult(k).velocity = roninVelocity(:,k);
    roninResult(k).speed = norm(roninVelocity(:,k));
end


end

