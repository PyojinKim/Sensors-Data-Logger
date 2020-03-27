clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;

addpath('devkit_KITTI_GPS');


%% 1) build consistent WiFi RSSI vector and Tango VIO pose in global inertial frame

% load dataset lists (Android Sensors-Data-Logger App from ASUS Tango)
expCase = 5;
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
    manual_alignment_Asus_Tango_SFU_Multiple_Buildings;
    R = angle2rotmtx([0;0;(deg2rad(yaw))]);
    R = R(1:2,1:2);
    t = [tx;ty];
    
    
    % extract WiFi centric data with Tango VIO
    datasetDirectory = [datasetPath '/' datasetList(k).name];
    wifiScanResult = extractWiFiCentricData(datasetDirectory, uniqueWiFiAPsBSSID, R, t);
    
    
    % save WiFi scan result
    datasetWiFiScanResult{k} = wifiScanResult;
    k
end


% plot Tango VIO with WiFi RSSI scan location together
distinguishableColors = distinguishable_colors(numDatasetList);
figure; hold on; grid on; axis equal;
for k = 1:numDatasetList
    wifiScanLocation = [datasetWiFiScanResult{k}.trueLocation];
    plot(wifiScanLocation(1,:),wifiScanLocation(2,:),'d','color',distinguishableColors(k,:),'LineWidth',1.5);
end
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); hold off;
set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure


%% 2) RSSI Fingerprinting Localization with query RSSI vector

% construct WiFi fingerprint database
wifiFingerprintDatabase = [];
for k = 1:48
    wifiFingerprintDatabase = [wifiFingerprintDatabase, datasetWiFiScanResult{k}];
end


% choose test WiFi scan dataset for WiFi localization
testWiFiScanResult = [];
for k = 49:55
    testWiFiScanResult = [testWiFiScanResult, datasetWiFiScanResult{k}];
end
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
plot([testWiFiScanResult.errorLocation]); grid on; axis tight;
xlabel('WiFi Scan Location Index'); ylabel('Error Distance (m)');
set(gcf,'Units','pixels','Position',[350 350 1280 480]);  % modify figure size


% plot 2D arrow location error
trueTrajectory = [testWiFiScanResult.trueLocation];
queryTrajectory = [testWiFiScanResult.queryLocation];
figure;
h_true = plot(trueTrajectory(1,:),trueTrajectory(2,:),'k*-','LineWidth',1.0); hold on; grid on;
h_WiFi = plot(queryTrajectory(1,:),queryTrajectory(2,:),'m*-','LineWidth',1.0);
for k = 1:numTestWiFiScan
    trueLocation = testWiFiScanResult(k).trueLocation;
    queryLocation = testWiFiScanResult(k).queryLocation;
    mArrow3([trueLocation;0], [queryLocation;0], 'color', 'red', 'stemWidth', 0.15);
end
xlabel('x [m]'); ylabel('y [m]'); axis equal; axis tight; hold off;
set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure


%% heat map plot

% re-arrange WiFi scan location
queryIndex = 25;
rewardResult = testWiFiScanResult(queryIndex).rewardResult;
maxRewardIndex = testWiFiScanResult(queryIndex).maxRewardIndex;
trueLocation = testWiFiScanResult(queryIndex).trueLocation;

databaseWiFiScanLocation = [wifiFingerprintDatabase(:).trueLocation];
maxRewardWiFiScanLocation = [wifiFingerprintDatabase(maxRewardIndex).trueLocation];


% plot WiFi scan location with distance (reward function) heat map
figure;
scatter(databaseWiFiScanLocation(1,:),databaseWiFiScanLocation(2,:),100,rewardResult,'.'); hold on; grid on;
plot(trueLocation(1),trueLocation(2),'kd','LineWidth',3);
plot(maxRewardWiFiScanLocation(1,:),maxRewardWiFiScanLocation(2,:),'md','LineWidth',3);
colormap(jet); colorbar;
xlabel('x [m]'); ylabel('y [m]'); axis equal; axis tight;
set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure


% plot reward metric result
figure;
plot(rewardResult); grid on; axis tight;
xlabel('WiFi Scan Location Index in Fingerprint Database'); ylabel('Reward Metric');


%% 3) manual Google FLP and Tango VIO alignment

% load labeled Google FLP result
numDatasetList = size(datasetList,1);
datasetGoogleFLPResult = cell(1,numDatasetList);
for k = 1:numDatasetList
    
    % read manual alignment result
    expCase = k;
    manual_alignment_Asus_Tango_SFU_Multiple_Buildings;
    R = angle2rotmtx([0;0;(deg2rad(yaw))]);
    R = R(1:2,1:2);
    t = [tx;ty];
    
    
    % extract Google FLP centric data with Tango VIO
    datasetDirectory = [datasetPath '/' datasetList(k).name];
    GoogleFLPResult = extractGoogleFLPCentricData(datasetDirectory, R, t, 25.0);
    
    
    % save Google FLP result
    datasetGoogleFLPResult{k} = GoogleFLPResult;
    k
end


% plot Tango VIO with Google FLP together
distinguishableColors = distinguishable_colors(numDatasetList);
figure(1); hold on; grid on; axis equal;
for k = 1:numDatasetList
    GoogleFLPLocation = [datasetGoogleFLPResult{k}.trueLocation];
    plot(GoogleFLPLocation(1,:),GoogleFLPLocation(2,:),'d','color',distinguishableColors(k,:),'LineWidth',1.5);
end
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); axis equal; axis tight; hold off;
set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure


% unify Google FLP inertial frame in meter
datasetGoogleFLPResult = unifyGoogleFLPMeterFrameForWiFiSfM(datasetGoogleFLPResult);


% manual coordinate alignment w.r.t. Tango VIO global inertial frame
datasetGoogleFLPLocationMeter = [];
for k = 1:numDatasetList
    GoogleFLPResult = datasetGoogleFLPResult{k};
    datasetGoogleFLPLocationMeter = [datasetGoogleFLPLocationMeter, [GoogleFLPResult.locationMeter]];
end
R = angle2rotmtx([0;0;(deg2rad(-13.5))]);
t = [1;0];
temp = R(1:2,1:2) * datasetGoogleFLPLocationMeter + t;


% plot Tango VIO location
figure(1); hold on; grid on; axis equal; axis tight;
h_FLP = plot(temp(1,:),temp(2,:),'*-','color',distinguishableColors(1,:),'LineWidth',1.0); grid on; axis equal;
xlabel('X [m]','FontName','Times New Roman','FontSize',15);
ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure
delete(h_FLP);


% Google FLP manual coordinate alignment
for k = 1:numDatasetList
    
    % current Google FLP data
    GoogleFLPResult = datasetGoogleFLPResult{k};
    numGoogleFLP = size(GoogleFLPResult,2);
    for m = 1:numGoogleFLP
        transformedFLPLocation = (R(1:2,1:2) * GoogleFLPResult(m).locationMeter + t);
        GoogleFLPResult(m).locationMeter = transformedFLPLocation;
    end
    
    % save Google FLP data
    datasetGoogleFLPResult{k} = GoogleFLPResult;
end


for k = 1:numDatasetList
    
    % current Google FLP data
    GoogleFLPResult = datasetGoogleFLPResult{k};
    numGoogleFLP = size(GoogleFLPResult,2);
    for m = 1:numGoogleFLP
        trueLocation = GoogleFLPResult(m).trueLocation;
        FLPLocation = GoogleFLPResult(m).locationMeter;
        GoogleFLPResult(m).errorLocation = norm(FLPLocation - trueLocation);
    end
    
    % save Google FLP data
    datasetGoogleFLPResult{k} = GoogleFLPResult;
end


% choose test Google FLP data
testGoogleFLPResult = [];
for k = 49:55
    testGoogleFLPResult = [testGoogleFLPResult, datasetGoogleFLPResult{k}];
end
numTestGoogleFLP = size(testGoogleFLPResult,2);


% plot Google FLP location error
figure;
plot([testGoogleFLPResult.errorLocation]); grid on; axis tight;
xlabel('Google FLP Location Index'); ylabel('Error Distance (m)');
set(gcf,'Units','pixels','Position',[350 350 1280 480]);  % modify figure size


% plot 2D arrow location error
trueTrajectory = [testGoogleFLPResult.trueLocation];
FLPTrajectory = [testGoogleFLPResult.locationMeter];
figure;
plot(trueTrajectory(1,:),trueTrajectory(2,:),'k*-','LineWidth',1.0); hold on; grid on;
plot(FLPTrajectory(1,:),FLPTrajectory(2,:),'m*-','LineWidth',1.0);
for k = 1:numTestGoogleFLP
    trueLocation = testGoogleFLPResult(k).trueLocation;
    FLPLocation = testGoogleFLPResult(k).locationMeter;
    mArrow3([trueLocation;0], [FLPLocation;0], 'color', 'red', 'stemWidth', 0.15);
end
xlabel('x [m]'); ylabel('y [m]'); axis equal; axis tight; hold off;
set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure










