function [wifiScanResult] = parseWiFiTextFile(wifiTextFile)

% open wifi text file
wifiTextFileID = fopen(wifiTextFile);
tline = fgetl(wifiTextFileID);


% construct WiFi scan results
nanoSecondToSecond = 1000000000;
wifiScanSize = 10000;
wifiScanResult = struct('timestamp', cell(1,wifiScanSize), 'numberOfAPs', cell(1,wifiScanSize), 'wifiAPsResult', cell(1,wifiScanSize));
numberOfWifiScan = 0;
while (true)
    
    % read the current number of APs
    numberOfWifiScan = numberOfWifiScan + 1;
    tline = fgetl(wifiTextFileID);
    numberOfAPs = str2double(tline);
    
    % check end of the wifi text file
    if (isnan(numberOfAPs))
        break;
    end
    
    % save each AP information per WiFi scan
    wifiAPsResult = struct('timestamp', cell(1,numberOfAPs), 'BSSID', cell(1,numberOfAPs), 'RSSI', cell(1,numberOfAPs), 'frequency', cell(1,numberOfAPs));
    for k = 1:numberOfAPs
        
        % read each AP information
        eachWifiAPResult = strsplit(fgetl(wifiTextFileID), char(9));
        wifiAPsResult(k).timestamp = (str2double(eachWifiAPResult{1}) / nanoSecondToSecond);
        wifiAPsResult(k).BSSID = eachWifiAPResult{2};
        wifiAPsResult(k).RSSI = str2double(eachWifiAPResult{3});
        wifiAPsResult(k).frequency = str2double(eachWifiAPResult{4});
    end
    
    % save each WiFi scan information
    wifiScanResult(numberOfWifiScan).timestamp = mean([wifiAPsResult(:).timestamp]);
    wifiScanResult(numberOfWifiScan).numberOfAPs = numberOfAPs;
    wifiScanResult(numberOfWifiScan).wifiAPsResult = wifiAPsResult;
end
wifiScanResult(numberOfWifiScan:end) = [];


% close wifi text file
fclose(wifiTextFileID);


end

