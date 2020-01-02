clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;

addpath('devkit_KITTI_GPS');


%% 1) build consistent Tango VIO pose in global inertial frame

% load dataset lists (Android Sensors-Data-Logger App from ASUS Tango)
expCase = 1;
setupParams_WiFi_SfM;
datasetList = loadDatasetList(datasetPath);


% parse all pose.txt files
numDatasetList = size(datasetList,1);
datasetTangoPoseResult = cell(1,numDatasetList);
for k = 1:numDatasetList
    
    % parse pose.txt file
    poseTextFile = [datasetPath '/' datasetList(k).name '/pose.txt'];
    TangoPoseResult = parseTangoPoseTextFile(poseTextFile);
    
    % read manual alignment result
    expCase = k;
    manual_alignment_Asus_Tango_SFU_TASC1_8000;
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
load([datasetPath '/uniqueWiFiAPsBSSID.mat']);
for k = 1:numDatasetList
    
    % current WiFi scan result
    wifiScanResult = datasetWiFiScanResult{k};
    
    % vectorize WiFi RSSI for each WiFi scan
    wifiScanRSSI = vectorizeWiFiRSSI(wifiScanResult, uniqueWiFiAPsBSSID);
    wifiScanRSSI = filterWiFiRSSI(wifiScanRSSI, -100);
    
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
for k = 1:(numDataset - 1)
    wifiFingerprintDatabase = [wifiFingerprintDatabase, datasetWiFiScanResult{k}];
end


% choose test WiFi scan dataset for WiFi localization
testWiFiScanResult = datasetWiFiScanResult{numDataset};
numTestWiFiScan = size(testWiFiScanResult,2);
for queryIndex = 1:numTestWiFiScan
    
    % current RSSI vector and true position from Tango VIO
    queryRSSI = testWiFiScanResult(queryIndex).RSSI;
    queryTruePosition = testWiFiScanResult(queryIndex).location;
    
    % query RSSI vector against WiFi fingerprint database
    [queryPosition, maxRewardIndex, rewardResult] = queryWiFiRSSI(queryRSSI, wifiFingerprintDatabase);
    
    % save the query result
    testWiFiScanResult(queryIndex).queryPosition = queryPosition;
    testWiFiScanResult(queryIndex).maxRewardIndex = maxRewardIndex;
    testWiFiScanResult(queryIndex).rewardResult = rewardResult;
    testWiFiScanResult(queryIndex).errorLocation = norm(queryPosition - queryTruePosition);
end


% plot query (estimated) location error
figure;
plot([testWiFiScanResult(:).errorLocation]); grid on; axis tight;
xlabel('WiFi Scan Location Index'); ylabel('Error Distance (m)');


% plot 3D arrow location error
trueTrajectory = [testWiFiScanResult(:).location];
queryTrajectory = [testWiFiScanResult(:).queryPosition];
figure;
h_true = plot3(trueTrajectory(1,:),trueTrajectory(2,:),trueTrajectory(3,:),'k*-','LineWidth',1.0); hold on; grid on;
h_WiFi = plot3(queryTrajectory(1,:),queryTrajectory(2,:),queryTrajectory(3,:),'m*-','LineWidth',1.0);
for k = 1:numTestWiFiScan
    trueLocation = testWiFiScanResult(k).location;
    queryLocation = testWiFiScanResult(k).queryPosition;
    mArrow3(trueLocation, queryLocation, 'color', 'red', 'stemWidth', 0.04);
end
plot_inertial_frame(0.5); axis equal; view(154,39);
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');


%% heat map plot

% re-arrange WiFi scan location
queryIndex = 25;
rewardResult = testWiFiScanResult(queryIndex).rewardResult;
maxRewardIndex = testWiFiScanResult(queryIndex).maxRewardIndex;
trueLocation = testWiFiScanResult(queryIndex).location;

databaseWiFiScanLocation = [wifiFingerprintDatabase(:).location];
maxRewardWiFiScanLocation = [wifiFingerprintDatabase(maxRewardIndex).location];


% plot WiFi scan location with distance (reward function) heat map
figure;
scatter3(databaseWiFiScanLocation(1,:),databaseWiFiScanLocation(2,:),databaseWiFiScanLocation(3,:),100,rewardResult,'.'); hold on; grid on;
plot3(trueLocation(1),trueLocation(2),trueLocation(3)+0.5,'kd','LineWidth',3);
plot3(maxRewardWiFiScanLocation(1,:),maxRewardWiFiScanLocation(2,:),maxRewardWiFiScanLocation(3,:)+0.5,'md','LineWidth',3);
colormap(jet); colorbar;
plot_inertial_frame(0.5); axis equal; view(154,39);
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');

% figure options
f = FigureRotator(gca());


% plot reward metric result
figure;
plot(rewardResult); grid on; axis tight;
xlabel('WiFi Scan Location Index in Fingerprint Database'); ylabel('Reward Metric');






