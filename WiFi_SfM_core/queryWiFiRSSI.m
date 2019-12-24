function [rewardResult] = queryWiFiRSSI(queryRSSI, wifiFingerprintDatabase)

% compare query RSSI to WiFi RSSI database
numLabeledWiFiScan = size(wifiFingerprintDatabase,2);
rewardResult = zeros(1,numLabeledWiFiScan);
for k = 1:numLabeledWiFiScan
    
    % calculate reward function based on the RSSI vectors
    databaseRSSI = wifiFingerprintDatabase(k).RSSI;
    rewardResult(k) = computeRewardMetric(queryRSSI, databaseRSSI);
end


end


%% distance metric (deprecated)

% % compare query RSSI to WiFi RSSI database
% numLabeledWiFiScan = size(wifiFingerprintDatabase,2);
% distanceResult = 50 * ones(1,numLabeledWiFiScan);
% for k = 1:numLabeledWiFiScan
%
%     % compute RSSI distance metric
%     databaseRSSI = wifiFingerprintDatabase(k).RSSI;
%     distance = computeDistanceMetric(queryRSSI, databaseRSSI, 'L1');
%     distanceResult(k) = distance;
% end
%
%
% % find top five index
% distanceResult(queryIndex) = 100;
% [~,firstIndex] = min(distanceResult);
%
%
% figure;
% plot(distanceResult);
% xlabel('WiFi Scan Location Index'); ylabel('Distance Metric (L1)');
%
