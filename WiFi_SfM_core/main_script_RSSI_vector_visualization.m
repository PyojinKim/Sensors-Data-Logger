clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;


%% common setting to read text files

delimiter = ' ';
headerlinesIn = 1;
nanoSecondToSecond = 1000000000;


%% 1)

% parse wifi.txt file
[wifiScanResult] = parseWiFiTextFile('wifi.txt');


% vectorize WiFi RSSI for each WiFi scan
[wifiScanRSSI,~] = vectorizeWiFiRSSI(wifiScanResult);


% parse pose.txt file (from ASUS Tango)
[TangoPoseResult] = parseTangoPoseTextFile('pose.txt');


tempRSSI = [];
for k = 1:size(wifiScanRSSI,2)
    tempRSSI = [tempRSSI, wifiScanRSSI(k).RSSI];
end


coeff = pca(tempRSSI);



%%

poseTime = [TangoPoseResult.timestamp].';
wifiTime = [wifiScanRSSI.timestamp].';





































