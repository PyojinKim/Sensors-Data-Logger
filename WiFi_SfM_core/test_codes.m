

queryRSSI = wifiScanRSSI(20).RSSI;



numWiFiScan = size(wifiScanRSSI,2);
distanceResult = 50 * ones(1,numWiFiScan);
numUniqueAPs = size(queryRSSI,1);
for k = 1:numWiFiScan
    
    %
    testRSSI = wifiScanRSSI(k).RSSI;
    distanceSum = 0;
    distanceCount = 0;
    for m = 1:numUniqueAPs
        
        % compute the difference
        a = queryRSSI(m);
        b = testRSSI(m);
        if ((a ~= -200) && (b ~= -200))
            %distanceSum = distanceSum + ((a - b)^2);    % L2 distance
            distanceSum = distanceSum + abs(a - b);        % L1 distance
            distanceCount = distanceCount + 1;
        end
    end
    
    % save the average distance metric
    if ((distanceCount ~= 0) && (distanceCount > 5))
        %distanceResult(k) = sqrt(distanceSum / distanceCount);   % L2 distance
        distanceResult(k) = distanceSum / distanceCount;             % L1 distance
    end
end



figure;
plot(distanceResult);
xlabel('WiFi Scan Location Index'); ylabel('Distance Metric (L1)');

[~,index] = min(distanceResult);
