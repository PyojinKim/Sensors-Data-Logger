clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;


%% common setting to read text files

delimiter = ' ';
headerlinesIn = 1;
nanoSecondToSecond = 1000000000;


%%


% load dataset lists (Android Sensors-Data-Logger App from ASUS Tango)
datasetPath = 'G:/Smartphone_Dataset/4_WiFi_SfM/Asus_Tango';


[uniqueWiFiAPsBSSID, numUniqueBSSID] = buildBSSIDMap(datasetPath);












%% 







%% 1) read





%%




% parse wifi.txt file
[wifiScanResult] = parseWiFiTextFile('wifi.txt');


% vectorize WiFi RSSI for each WiFi scan
[wifiScanRSSI,~] = vectorizeWiFiRSSI(wifiScanResult);
[wifiScanRSSI] = filterWiFiRSSI(wifiScanRSSI, -75);


% parse pose.txt file (from ASUS Tango)
[TangoPoseResult] = parseTangoPoseTextFile('pose.txt');


