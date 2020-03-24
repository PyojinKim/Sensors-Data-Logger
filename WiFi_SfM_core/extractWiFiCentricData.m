function [wifiScanResult] = extractWiFiCentricData(datasetDirectory, uniqueWiFiAPsBSSID, R, t)

% parse wifi.txt file / vectorize WiFi RSSI for each WiFi scan
wifiScanResult = parseWiFiTextFile([datasetDirectory '/wifi.txt']);
wifiScanResult = vectorizeWiFiRSSI(wifiScanResult, uniqueWiFiAPsBSSID);
wifiScanResult = filterWiFiRSSI(wifiScanResult, -100);


% parse pose.txt file / transform to global inertial frame
TangoPoseResult = parseTangoPoseTextFile([datasetDirectory '/pose.txt']);
numPose = size(TangoPoseResult,2);
for m = 1:numPose
    transformedTangoPose = (R * TangoPoseResult(m).stateEsti_Tango(1:2) + t);
    TangoPoseResult(m).stateEsti_Tango = transformedTangoPose;
end


% label consistent WiFi RSSI vector with Tango VIO location
numWiFiScan = size(wifiScanResult,2);
for m = 1:numWiFiScan
    
    % find the closest Tango pose timestamp and true location
    [timeDifference, indexTango] = min(abs(wifiScanResult(m).timestamp - [TangoPoseResult.timestamp]));
    if (timeDifference < 0.5)
        wifiScanResult(m).trueLocation = TangoPoseResult(indexTango).stateEsti_Tango;
    end
end


% refine unlabeled WiFi scan result
for m = numWiFiScan:-1:1
    if (isempty(wifiScanResult(m).trueLocation))
        wifiScanResult(m) = [];
    end
end


end

