function [wifiScanRSSI] = vectorizeWiFiRSSI(wifiScanResult, uniqueWiFiAPsBSSID)

% construct WiFi RSSI vector
numWiFiScan = size(wifiScanResult,2);
numUniqueBSSID = size(uniqueWiFiAPsBSSID,1);
wifiScanRSSI = struct('timestamp', cell(1,numWiFiScan), 'RSSI', cell(1,numWiFiScan));
for k = 1:numWiFiScan
    
    % package current WiFi APs BSSID
    tempWiFiAPsBSSID = [];
    numWiFiAPs = wifiScanResult(k).numberOfAPs;
    for m = 1:numWiFiAPs
        
        % save current WiFi BSSID
        currentBSSID = convertCharsToStrings(wifiScanResult(k).wifiAPsResult(m).BSSID);
        tempWiFiAPsBSSID = [tempWiFiAPsBSSID; currentBSSID];
    end
    
    
    % construct WiFi RSSI vector
    uniqueRSSIVector = -200 * ones(numUniqueBSSID,1);
    for m = 1:numUniqueBSSID
        
        % find unique WiFi BSSID in current WiFi scan
        indexWiFiAPs = find(uniqueWiFiAPsBSSID(m) == tempWiFiAPsBSSID);
        if (~isempty(indexWiFiAPs))
            uniqueRSSIVector(m) = wifiScanResult(k).wifiAPsResult(indexWiFiAPs).RSSI;
        end
    end
    
    
    % save WiFi RSSI vector for each WiFi scan
    wifiScanRSSI(k).timestamp = wifiScanResult(k).timestamp;
    wifiScanRSSI(k).RSSI = uniqueRSSIVector;
end


end

