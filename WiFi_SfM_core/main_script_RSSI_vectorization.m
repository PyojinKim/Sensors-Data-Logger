clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;


%% 1) build consistent Tango VIO pose vector

% load dataset lists (Android Sensors-Data-Logger App from ASUS Tango)
datasetPath = 'G:/Smartphone_Dataset/4_WiFi_SfM/Asus_Tango';
datasetList = dir(datasetPath);
datasetList(1:2) = [];


% parse all pose.txt files
numDatasetList = size(datasetList,1);
datasetTangoPoseResult = cell(1,numDatasetList);
for k = 1:numDatasetList
    
    % parse pose.txt file
    currentPoseTextFile = [datasetPath '/' datasetList(k).name '/pose.txt'];
    TangoPoseResult = parseTangoPoseTextFile(currentPoseTextFile);
    
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
    currentWiFiTextFile = [datasetPath '/' datasetList(k).name '/wifi.txt'];
    wifiScanResult = parseWiFiTextFile(currentWiFiTextFile);
    
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

for k = 1:numDatasetList
    
    % current Tango VIO pose / WiFi RSSI vector
    TangoPoseResult = datasetTangoPoseResult{k};
    wifiScanRSSI = datasetWiFiScanResult{k};
    
    % label WiFi RSSI vector
    numWiFiScan = size(wifiScanRSSI,2);
    for m = 1:numWiFiScan
        
        % find the closest Tango pose time
        [timeDifference, indexTango] = min(abs(wifiScanRSSI(m).timestamp - [TangoPoseResult.timestamp]));
        
        % save corresponding Tango pose location
        wifiScanRSSI(m).location = TangoPoseResult(indexTango).stateEsti_Tango;
    end
    
    % save labeled WiFi RSSI vector
    datasetWiFiScanResult{k} = wifiScanRSSI;
end


%% 4)

% accumulate labeled WiFi RSSI vector
labeledWiFiScanRSSI = [];
numDataset = size(datasetWiFiScanResult,2);
for k = 2:numDataset
    labeledWiFiScanRSSI = [labeledWiFiScanRSSI, datasetWiFiScanResult{k}];
end


% choose query RSSI vector
queryIndex = 20;
queryRSSI = datasetWiFiScanResult{1}(queryIndex).RSSI;


% compute RSSI distance metric
numWiFiScan = size(labeledWiFiScanRSSI,2);
distanceResult = 50 * ones(1,numWiFiScan);
numUniqueAPs = size(queryRSSI,1);
for k = 1:numWiFiScan
    
    %
    testRSSI = labeledWiFiScanRSSI(k).RSSI;
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
%distanceResult(queryIndex) = 50;


figure;
plot(distanceResult);
xlabel('WiFi Scan Location Index'); ylabel('Distance Metric (L1)');

[~,index] = min(distanceResult);







%%


% 2) plot Tango VIO motion estimation results
figure;
h_Tango = plot3(syncTangoTrajectory(1,:),syncTangoTrajectory(2,:),syncTangoTrajectory(3,:),'k','LineWidth',2); hold on; grid on;
plot_inertial_frame(0.5); axis equal; view(26, 73);
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); zlabel('z [m]','fontsize',10);

m = syncWiFiRSSI_index(20);
plot3(syncTangoTrajectory(1,m),syncTangoTrajectory(2,m),syncTangoTrajectory(3,m),'ro','LineWidth',5);

m = syncWiFiRSSI_index(61);
plot3(syncTangoTrajectory(1,m),syncTangoTrajectory(2,m),syncTangoTrajectory(3,m),'bo','LineWidth',5);

for m = syncWiFiRSSI_index
    
    plot3(syncTangoTrajectory(1,m),syncTangoTrajectory(2,m),syncTangoTrajectory(3,m),'ro','LineWidth',5);
    m
    
end






view(154,39)














