clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;

addpath('devkit_KITTI_GPS');


%% 1) build consistent WiFi RSSI vector and Tango VIO pose in global inertial frame

% load dataset lists (Android Sensors-Data-Logger App from ASUS Tango)
expCase = 1;
setupParams_WiFi_SfM;
datasetList = loadDatasetList(datasetPath);


% load unique WiFi RSSID Map
load([datasetPath '/uniqueWiFiAPsBSSID.mat']);


% load labeled WiFi scan result
numDatasetList = size(datasetList,1);
datasetWiFiScanResult = cell(1,numDatasetList);
for k = 1:numDatasetList
    
    % read manual alignment result
    expCase = k;
    manual_alignment_Asus_Tango_SFU_TASC1_8000;
    R = angle2rotmtx([0;0;(deg2rad(yaw))]);
    t = [tx; ty; tz];
    
    % extract WiFi centric data with Tango VIO
    datasetDirectory = [datasetPath '/' datasetList(k).name];
    wifiScanResult = extractWiFiCentricData(datasetDirectory, uniqueWiFiAPsBSSID, R, t);
    
    % save WiFi scan result
    datasetWiFiScanResult{k} = wifiScanResult;
end


% plot Tango VIO with WiFi RSSI scan location together
k = 10;
wifiScanLocation = [datasetWiFiScanResult{k}.trueLocation];
figure;
plot3(wifiScanLocation(1,:),wifiScanLocation(2,:),wifiScanLocation(3,:),'rd','LineWidth',2); hold on; grid on;
plot_inertial_frame(0.5); axis equal; view(154,39)
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); zlabel('z [m]','fontsize',10); hold off;


%% 2) RSSI Fingerprinting Localization with query RSSI vector

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
    trueLocation = testWiFiScanResult(queryIndex).trueLocation;
    
    % query RSSI vector against WiFi fingerprint database
    [queryLocation, maxRewardIndex, rewardResult] = queryWiFiRSSI(queryRSSI, wifiFingerprintDatabase);
    
    % save the query result
    testWiFiScanResult(queryIndex).queryLocation = queryLocation;
    testWiFiScanResult(queryIndex).maxRewardIndex = maxRewardIndex;
    testWiFiScanResult(queryIndex).rewardResult = rewardResult;
    testWiFiScanResult(queryIndex).errorLocation = norm(queryLocation - trueLocation);
end


% plot query (estimated) location error
figure;
plot([testWiFiScanResult(:).errorLocation]); grid on; axis tight;
xlabel('WiFi Scan Location Index'); ylabel('Error Distance (m)');


% plot 3D arrow location error
trueTrajectory = [testWiFiScanResult(:).trueLocation];
queryTrajectory = [testWiFiScanResult(:).queryLocation];
figure;
h_true = plot3(trueTrajectory(1,:),trueTrajectory(2,:),trueTrajectory(3,:),'k*-','LineWidth',1.0); hold on; grid on;
h_WiFi = plot3(queryTrajectory(1,:),queryTrajectory(2,:),queryTrajectory(3,:),'m*-','LineWidth',1.0);
for k = 1:numTestWiFiScan
    trueLocation = testWiFiScanResult(k).trueLocation;
    queryLocation = testWiFiScanResult(k).queryLocation;
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






