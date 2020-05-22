function [RoninIO] = extractRoninCentricData(datasetDirectory, roninInterval, roninYawRotation, accuracyThreshold, uniqueWiFiAPsBSSID)

% parse ronin.txt file / compute RoNIN velocity and speed
RoninIO = parseRoninTextFile([datasetDirectory '/ronin.txt'], roninInterval, roninYawRotation);
RoninIO = computeRoninVelocity(RoninIO);
RoninIOTime = [RoninIO.timestamp];
numRoninIO = size(RoninIO,2);


% parse wifi.txt file / find the closest WiFi Scan data
wifiScan = parseWiFiTextFile([datasetDirectory '/wifi.txt']);
numWifiScan = size(wifiScan,2);
for k = 1:numWifiScan
    
    % current WiFi Scan data
    timestamp = wifiScan(k).timestamp;
    wifiAPsResult = wifiScan(k).wifiAPsResult;
    
    
    % save WiFi Scan data in RoNIN IO
    [timeDifference, indexRoninIO] = min(abs(timestamp - RoninIOTime));
    if (timeDifference < 0.5)
        RoninIO(indexRoninIO).wifiAPsResult = wifiAPsResult;
    end
end


% parse FLP.txt / find the closest Google FLP data
GoogleFLP = parseGoogleFLPTextFile([datasetDirectory '/FLP.txt']);
numGoogleFLP = size(GoogleFLP,2);
for k = 1:numGoogleFLP
    
    % current Google FLP data
    timestamp = GoogleFLP(k).timestamp;
    locationDegree = GoogleFLP(k).locationDegree;
    locationMeter = GoogleFLP(k).locationMeter;
    accuracyMeter = GoogleFLP(k).accuracyMeter;
    
    
    % save Google FLP data in RoNIN IO
    [timeDifference, indexRoninIO] = min(abs(timestamp - RoninIOTime));
    if (timeDifference < 0.5)
        RoninIO(indexRoninIO).FLPLocationDegree = locationDegree;
        RoninIO(indexRoninIO).FLPLocationMeter = locationMeter;
        RoninIO(indexRoninIO).FLPAccuracyMeter = accuracyMeter;
    end
end


% refine invalid RoNIN result from Google FLP
numRonin = size(RoninIO,2);
for k = 1:numRonin
    if (RoninIO(k).FLPAccuracyMeter > accuracyThreshold)
        RoninIO(k).FLPLocationDegree = [];
        RoninIO(k).FLPLocationMeter = [];
        RoninIO(k).FLPAccuracyMeter = [];
    end
end


% parse magnet.txt file / find the closest magnetic field data
magnet = parseMagnetTextFile([datasetDirectory '/magnet.txt']);
magnetTime = [magnet.timestamp];
for k = 1:numRoninIO
    [timeDifference, indexMagnet] = min(abs(RoninIO(k).timestamp - magnetTime));
    if (timeDifference < 0.5)
        RoninIO(k).magnet = magnet(indexMagnet).magnet;
    end
end


% parse game_rv.txt file / find the closest game rotation vector (R_gb)
gameRV = parseGameRVTextFile([datasetDirectory '/game_rv.txt']);
gameRVTime = [gameRV.timestamp];
for k = 1:numRoninIO
    [timeDifference, indexGameRV] = min(abs(RoninIO(k).timestamp - gameRVTime));
    if (timeDifference < 0.5)
        RoninIO(k).R_gb = gameRV(indexGameRV).R_gb;
    end
end


% parse wifi.txt file / vectorize WiFi RSSI for each WiFi scan
wifiScan = parseWiFiTextFile([datasetDirectory '/wifi.txt']);
wifiScan = vectorizeWiFiRSSI(wifiScan, uniqueWiFiAPsBSSID);
wifiScan = filterWiFiRSSI(wifiScan, -100);
numWifiScan = size(wifiScan,2);
RoninIOTime = [RoninIO.timestamp];
for k = 1:numWifiScan
    
    % current WiFi scan data
    timestamp = wifiScan(k).timestamp;
    RSSI = wifiScan(k).RSSI;
    
    
    % save WiFi scan data in RoNIN IO
    [timeDifference, indexRoninIO] = min(abs(timestamp - RoninIOTime));
    if (timeDifference < 0.5)
        RoninIO(indexRoninIO).RSSI = RSSI;
    end
end


% add dummy WiFi RSSI vector
numRoninIO = size(RoninIO,2);
for k = 1:numRoninIO
    if (isempty(RoninIO(k).RSSI))
        RoninIO(k).RSSI = -200 * ones(1179,1);
    end
end


end


