function [index, distanceResult] = queryWiFiRSSI(queryRSSI, wifiFingerprintDatabase)

% compare query RSSI to WiFi RSSI database
numLabeledWiFiScan = size(wifiFingerprintDatabase,2);
distanceResult = 50 * ones(1,numLabeledWiFiScan);
numUniqueAPs = size(queryRSSI,1);
for k = 1:numLabeledWiFiScan
    
    % compute RSSI distance metric
    databaseRSSI = wifiFingerprintDatabase(k).RSSI;
    distanceSum = 0;
    distanceCount = 0;
    for m = 1:numUniqueAPs
        
        % compute the difference
        p = queryRSSI(m);
        q = databaseRSSI(m);
        if ((p == -200) && (q == -200))
            continue;
        else
            %distanceSum = distanceSum + ((p - q)^2);    % L2 distance
            distanceSum = distanceSum + abs(p - q);        % L1 distance
            distanceCount = distanceCount + 1;
        end
    end
    
    % save the average distance metric
    if ((distanceCount ~= 0) && (distanceCount > 10))
        %distanceResult(k) = sqrt(distanceSum / distanceCount);   % L2 distance
        distanceResult(k) = distanceSum / distanceCount;             % L1 distance
    end
end




%distanceResult(queryIndex) = 50;

%

[~,index] = min(distanceResult);








end

