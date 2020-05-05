clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;

addpath('devkit_KITTI_GPS');


%% 1) load Tango VIO data

% choose dataset path
datasetPath = 'G:\Smartphone_Dataset\4_WiFi_SfM\pyojin_Asus_Tango_SFU_Multiple_Buildings_withVIO';
datasetList = dir(datasetPath);
datasetList(1:2) = [];


% load unique WiFi RSSID Map
load([datasetPath '/uniqueWiFiAPsBSSID.mat']);


% load Tango VIO data
numDatasetList = 55;
datasetTangoVIO = cell(1,numDatasetList);
for k = 1:numDatasetList
    
    % parse pose.txt / FLP.txt
    datasetDirectory = [datasetPath '\' datasetList(k).name];
    TangoVIOInterval = 100;   % 200 Hz
    accuracyThreshold = 25;   % in meter
    TangoVIO = extractTangoVIOCentricData(datasetDirectory, TangoVIOInterval, accuracyThreshold, uniqueWiFiAPsBSSID);
    
    
    % save Tango VIO
    datasetTangoVIO{k} = TangoVIO;
    k
end


% unify Google FLP inertial frame in meter
datasetTangoVIO = unifyGoogleFLPMeterFrame(datasetTangoVIO);


% Google FLP visualization
for k = 1:numDatasetList
    
    % current Tango VIO data
    TangoVIO = datasetTangoVIO{k};
    TangoVIOLocation = [TangoVIO.FLPLocationMeter];
    
    
    % plot Tango VIO location
    distinguishableColors = distinguishable_colors(numDatasetList);
    figure(10); hold on; grid on; axis equal; axis tight;
    plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'*-','color',distinguishableColors(k,:),'LineWidth',1.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure
end


% label start and final FLP locations
for k = 1:numDatasetList
    
    % read manual alignment result
    expCase = k;
    manual_alignment_Asus_Tango_SFU_Multiple_Buildings_Landmarks;
    
    
    % update Tango VIO data
    TangoVIO = datasetTangoVIO{k};
    TangoVIO(1).FLPLocationMeter = startFLPLocationMeter;
    TangoVIO(1).FLPAccuracyMeter = FLPAccuracyMeter;
    TangoVIO(end).FLPLocationMeter = finalFLPLocationMeter;
    TangoVIO(end).FLPAccuracyMeter = FLPAccuracyMeter;
    
    
    % save Tango VIO
    datasetTangoVIO{k} = TangoVIO;
end


%% 2) optimize each Tango VIO against Google FLP

% initial 2D rigid body transformation w.r.t. Google FLP
for k = 1:numDatasetList
    
    % current Tango VIO data
    TangoVIO = datasetTangoVIO{k};
    
    
    % nonlinear optimization with Tango VIO drift correction model
    [TangoVIO] = optimizeEachTangoVIO(TangoVIO);
    datasetTangoVIO{k} = TangoVIO;
end


% optimized Tango VIO visualization
for k = 1:numDatasetList
    
    % current Tango VIO data
    TangoVIO = datasetTangoVIO{k};
    TangoVIOLocation = [TangoVIO.location];
    
    
    % plot Tango VIO location
    distinguishableColors = distinguishable_colors(numDatasetList);
    figure(10); hold on; grid on; axis equal; axis tight;
    plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'-','color',distinguishableColors(k,:),'LineWidth',1.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure
end


%% temporary codes for testing idea

%
for k = 1:numDatasetList
    
    % current Tango VIO data
    TangoVIO = datasetTangoVIO{k};
    
    
    % nonlinear optimization with Tango VIO drift correction model
    [TangoVIO] = optimizeEachTangoVIOwithScaleBias(TangoVIO);
    datasetTangoVIO{k} = TangoVIO;
end


%% temporary codes for WiFi similarity visualization

k = 2;

% current Tango VIO data
TangoVIO = datasetTangoVIO{k};
numTangoVIO = size(TangoVIO,2);
testWiFiScanResult = struct('timestamp',cell(1,numTangoVIO),'RSSI',cell(1,numTangoVIO),'trueLocation',cell(1,numTangoVIO));
numCount = 0;
for m = 1:numTangoVIO
    
    % check WiFi scan RSSI exist or not
    if (~isempty(TangoVIO(m).RSSI))
        
        numCount = numCount + 1;
        testWiFiScanResult(numCount).timestamp = TangoVIO(m).timestamp;
        testWiFiScanResult(numCount).RSSI = TangoVIO(m).RSSI;
        testWiFiScanResult(numCount).trueLocation = TangoVIO(m).location;
    end
end
testWiFiScanResult((numCount+1):end) = [];


testRoninIndex = [7 17 22 25 41];

% construct WiFi fingerprint database
wifiFingerprintDatabase = [];
for k = testRoninIndex
    
    % current Tango VIO data
    TangoVIO = datasetTangoVIO{k};
    numTangoVIO = size(TangoVIO,2);
    tempWiFiScanResult = struct('timestamp',cell(1,numTangoVIO),'RSSI',cell(1,numTangoVIO),'trueLocation',cell(1,numTangoVIO));
    numCount = 0;
    for m = 1:numTangoVIO
        
        % check WiFi scan RSSI exist or not
        if (~isempty(TangoVIO(m).RSSI))
            
            numCount = numCount + 1;
            tempWiFiScanResult(numCount).timestamp = TangoVIO(m).timestamp;
            tempWiFiScanResult(numCount).RSSI = TangoVIO(m).RSSI;
            tempWiFiScanResult(numCount).trueLocation = TangoVIO(m).location;
        end
    end
    tempWiFiScanResult((numCount+1):end) = [];
    
    
    % save WiFi scan results
    wifiFingerprintDatabase = [wifiFingerprintDatabase, tempWiFiScanResult];
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


testRoninIndex = [2 7 17 22 25 41];
for k = testRoninIndex
    
    % current Tango VIO data
    TangoVIO = datasetTangoVIO{k};
    TangoVIOLocation = [TangoVIO.location];
    
    
    % plot Tango VIO location
    distinguishableColors = distinguishable_colors(numDatasetList);
    plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'-','color','k','LineWidth',0.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
end


plot(trueLocation(1),trueLocation(2),'kd','LineWidth',3);
plot(maxRewardWiFiScanLocation(1,:),maxRewardWiFiScanLocation(2,:),'md','LineWidth',3);
colormap(jet); colorbar;
xlabel('x [m]'); ylabel('y [m]'); axis equal; axis tight;
set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure


% plot reward metric result
figure;
plot(rewardResult); grid on; axis tight;
xlabel('WiFi Scan Location Index in Fingerprint Database'); ylabel('Reward Metric');

















