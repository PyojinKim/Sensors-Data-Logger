function [uniqueWiFiAPsBSSID, numUniqueBSSID] = buildBSSIDMap(datasetPath)

% load dataset lists (Android Sensors-Data-Logger App from ASUS Tango)
datasetList = dir(datasetPath);
datasetList(1:2) = [];


% parse all wifi.txt files
numDatasetList = size(datasetList,1);
datasetWiFiScanResult = cell(1,numDatasetList);
for k = 1:numDatasetList
    
    % parse wifi.txt file
    currentWiFiTextFile = [datasetPath '/' datasetList(k).name '/wifi.txt'];
    wifiScanResult = parseWiFiTextFile(currentWiFiTextFile);
    
    % save WiFi scan result
    datasetWiFiScanResult{k} = wifiScanResult;
end


% extract all recorded WiFi BSSID
tempWiFiAPsBSSID = [];
for k = 1:numDatasetList
    
    % current WiFi scan result
    currentWiFiScanResult = datasetWiFiScanResult{k};
    numWiFiScan = size(currentWiFiScanResult,2);
    for m = 1:numWiFiScan
        
        % current number of APs
        numWiFiAPs = currentWiFiScanResult(m).numberOfAPs;
        for n = 1:numWiFiAPs
            
            % save current WiFi BSSID
            currentBSSID = convertCharsToStrings(currentWiFiScanResult(m).wifiAPsResult(n).BSSID);
            tempWiFiAPsBSSID = [tempWiFiAPsBSSID; currentBSSID];
        end
    end
end


% find unique WiFi BSSID
uniqueWiFiAPsBSSID = unique(tempWiFiAPsBSSID);
numUniqueBSSID = size(uniqueWiFiAPsBSSID,1);


end

