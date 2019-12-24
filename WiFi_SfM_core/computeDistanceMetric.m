function [distance] = computeDistanceMetric(queryRSSI, databaseRSSI, method)

% compute the distance between RSSI vectors
numUniqueAPs = size(queryRSSI,1);
distanceSum = 0;
distanceCount = 0;
for m = 1:numUniqueAPs
    
    % current element from RSSI vectors
    p = queryRSSI(m);
    q = databaseRSSI(m);
    
    % calculate the distance
    if ((p == -200) && (q == -200))
        continue;
    else
        
        % choose the distance based on the method
        if (strcmp(method,'L1'))
            distanceSum = distanceSum + abs(p - q);
            distanceCount = distanceCount + 1;
        elseif (strcmp(method,'L2'))
            distanceSum = distanceSum + ((p - q)^2);
            distanceCount = distanceCount + 1;
        end
    end
end


% calculate the average distance metric
distance = 100;
if ((distanceCount ~= 0) && (distanceCount > 15))
    
    % choose the distance based on the method
    if (strcmp(method,'L1'))
        distance = distanceSum / distanceCount;
    elseif (strcmp(method,'L2'))
        distance = sqrt(distanceSum / distanceCount);
    end
end


end

