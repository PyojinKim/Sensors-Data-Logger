clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;


%% 1) build consistent Tango VIO pose in global inertial frame

% load dataset lists (Android Sensors-Data-Logger App from ASUS Tango)
datasetPath = 'G:/Smartphone_Dataset/4_WiFi_SfM/Asus_Tango';
datasetList = dir(datasetPath);
datasetList(1:2) = [];


% parse all pose.txt files
numDatasetList = size(datasetList,1);
datasetTangoPoseResult = cell(1,numDatasetList);
for k = 1:numDatasetList
    
    % parse pose.txt file
    poseTextFile = [datasetPath '/' datasetList(k).name '/pose.txt'];
    TangoPoseResult = parseTangoPoseTextFile(poseTextFile);
    
    % read manual alignment result
    expCase = k;
    setupParams_Asus_Tango_Dataset;
    R = angle2rotmtx([0;0;(deg2rad(yaw))]);
    t = [tx; ty; tz];
    
    % transform to global inertial frame
    numPose = size(TangoPoseResult,2);
    for m = 1:numPose
        transformedTangoPose = (R * TangoPoseResult(m).stateEsti_Tango(1:3) + t);
        TangoPoseResult(m).stateEsti_Tango = transformedTangoPose;
    end
    
    % save Tango pose VIO result
    datasetTangoPoseResult{k} = TangoPoseResult;
end


%% 2) build consistent WiFi RSSI vector

% load dataset lists (Android Sensors-Data-Logger App from ASUS Tango)
datasetPath = 'G:/Smartphone_Dataset/4_WiFi_SfM/Asus_Tango';
datasetList = dir(datasetPath);
datasetList(1:2) = [];


% parse all wifi.txt files
numDatasetList = size(datasetList,1);
datasetWiFiScanResult = cell(1,numDatasetList);
for k = 1:numDatasetList
    
    % parse wifi.txt file
    wifiTextFile = [datasetPath '/' datasetList(k).name '/wifi.txt'];
    wifiScanResult = parseWiFiTextFile(wifiTextFile);
    
    % save WiFi scan result
    datasetWiFiScanResult{k} = wifiScanResult;
end


% load unique WiFI RSSID Map
load('uniqueWiFiAPsBSSID.mat');
for k = 1:numDatasetList
    
    % current WiFi scan result
    wifiScanResult = datasetWiFiScanResult{k};
    
    % vectorize WiFi RSSI for each WiFi scan
    wifiScanRSSI = vectorizeWiFiRSSI(wifiScanResult, uniqueWiFiAPsBSSID);
    wifiScanRSSI = filterWiFiRSSI(wifiScanRSSI, -80);
    
    % save WiFi RSSI vector
    datasetWiFiScanResult{k} = wifiScanRSSI;
end


%% 3) label consistent WiFi RSSI vector with Tango VIO location

% label all WiFi RSSI vector in global inertial frame
for k = 1:numDatasetList
    
    % current Tango VIO pose / WiFi RSSI vector
    TangoPoseResult = datasetTangoPoseResult{k};
    wifiScanRSSI = datasetWiFiScanResult{k};
    
    % label WiFi RSSI vector
    numWiFiScan = size(wifiScanRSSI,2);
    for m = 1:numWiFiScan
        
        % find the closest Tango pose timestamp
        [timeDifference, indexTango] = min(abs(wifiScanRSSI(m).timestamp - [TangoPoseResult.timestamp]));
        if (timeDifference < 5.0)
            
            % save corresponding Tango pose location
            wifiScanRSSI(m).location = TangoPoseResult(indexTango).stateEsti_Tango;
            wifiScanRSSI(m).dataset = datasetList(k).name;
        else
            error('Fail to find the closest Tango pose timestamp.... at %d', m);
        end
    end
    
    % save labeled WiFi RSSI vector
    datasetWiFiScanResult{k} = wifiScanRSSI;
end


% plot Tango VIO with WiFi RSSI scan location together
k = 1;
TangoPose = [datasetTangoPoseResult{k}.stateEsti_Tango];
wifiScanLocation = [datasetWiFiScanResult{k}.location];

figure;
plot3(TangoPose(1,:),TangoPose(2,:),TangoPose(3,:),'k','LineWidth',2); hold on; grid on;
plot3(wifiScanLocation(1,:),wifiScanLocation(2,:),wifiScanLocation(3,:),'ro','LineWidth',2);
plot_inertial_frame(0.5); axis equal; view(154,39)
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); zlabel('z [m]','fontsize',10); hold off;


%% 4) RSSI Fingerprinting Localization with query RSSI vector

% construct WiFi fingerprint database
wifiFingerprintDatabase = [];
numDataset = size(datasetWiFiScanResult,2);
for k = 1:numDataset
    wifiFingerprintDatabase = [wifiFingerprintDatabase, datasetWiFiScanResult{k}];
end


% choose query RSSI vector
queryIndex = 20;
queryRSSI = datasetWiFiScanResult{1}(queryIndex).RSSI;


%%

figure;
plot(distanceResult);
xlabel('WiFi Scan Location Index'); ylabel('Distance Metric (L1)');


%% heat map plot


norm(datasetWiFiScanResult{1}(queryIndex).location - wifiFingerprintDatabase(368).location)


% plot WiFi scan location with distance (reward function) heat map
labeledWiFiScanLocation = [wifiFingerprintDatabase(:).location];
X = labeledWiFiScanLocation(1,:);
Y = labeledWiFiScanLocation(2,:);
Z = labeledWiFiScanLocation(3,:);
C = distanceResult;

figure;
scatter3(X(:),Y(:),Z(:),100,C(:),'.');

colormap(jet);
colorbar;

plot_inertial_frame(0.5); axis equal; view(154,39)
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');

% figure options
f = FigureRotator(gca());








