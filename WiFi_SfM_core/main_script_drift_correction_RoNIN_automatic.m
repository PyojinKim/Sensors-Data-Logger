clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;

addpath('devkit_KITTI_GPS');


%% 1) load RoNIN IO data

% choose dataset path
datasetPath = 'G:\Smartphone_Dataset\4_WiFi_SfM\pyojin_Asus_Tango_SFU_Multiple_Buildings_withVIO';
datasetList = dir(datasetPath);
datasetList(1:2) = [];


% load unique WiFi RSSID Map
load([datasetPath '/uniqueWiFiAPsBSSID.mat']);


% load RoNIN IO data
numDatasetList = 55;
datasetRoninIO = cell(1,numDatasetList);
for k = 1:numDatasetList
    
    % extract RoNIN data
    datasetDirectory = [datasetPath '\' datasetList(k).name];
    roninInterval = 200;          % 1 Hz
    roninYawRotation = 0;       % degree
    RoninIO = extractRoninCentricData(datasetDirectory, roninInterval, roninYawRotation, 25.0, uniqueWiFiAPsBSSID);
    
    
    % save RoNIN IO
    datasetRoninIO{k} = RoninIO;
    k
end


% unify Google FLP inertial frame in meter
datasetRoninIO = unifyRoninIOGoogleFLPMeterFrame(datasetRoninIO);


% Google FLP visualization
for k = 1:numDatasetList
    
    % current RoNIN IO data
    RoninIO = datasetRoninIO{k};
    RoninIOLocation = [RoninIO.FLPLocationMeter];
    
    
    % plot RoNIN IO location
    distinguishableColors = distinguishable_colors(numDatasetList);
    figure(10); hold on; grid on; axis equal; axis tight;
    plot(RoninIOLocation(1,:),RoninIOLocation(2,:),'*-','color',distinguishableColors(k,:),'LineWidth',1.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure
end


% label start and final FLP locations
for k = 1:numDatasetList
    
    % read manual alignment result
    expCase = k;
    manual_alignment_Asus_Tango_SFU_Multiple_Buildings_Landmarks;
    
    
    % update RoNIN IO data
    RoninIO = datasetRoninIO{k};
    RoninIO(1).FLPLocationMeter = startFLPLocationMeter;
    RoninIO(1).FLPAccuracyMeter = FLPAccuracyMeter;
    RoninIO(end).FLPLocationMeter = finalFLPLocationMeter;
    RoninIO(end).FLPAccuracyMeter = FLPAccuracyMeter;
    
    
    % save RoNIN IO
    datasetRoninIO{k} = RoninIO;
end


%% 2) optimize each RoNIN IO against Google FLP

% initial 2D rigid body transformation w.r.t. Google FLP
for k = 1:numDatasetList
    
    % current RoNIN IO data
    RoninIO = datasetRoninIO{k};
    
    
    % nonlinear optimization with RoNIN drift correction model
    [RoninIO] = optimizeEachRoninIO(RoninIO);
    datasetRoninIO{k} = RoninIO;
end


% optimized RoNIN IO visualization
for k = 1:numDatasetList
    
    % current RoNIN IO data
    RoninIO = datasetRoninIO{k};
    RoninIOLocation = [RoninIO.location];
    
    
    % plot RoNIN IO location
    distinguishableColors = distinguishable_colors(numDatasetList);
    figure(10); hold on; grid on; axis equal; axis tight;
    plot(RoninIOLocation(1,:),RoninIOLocation(2,:),'-','color',distinguishableColors(k,:),'LineWidth',1.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure
end


%% temporary codes for testing idea

%
for k = 1:numDatasetList
    
    % current RoNIN IO data
    RoninIO = datasetRoninIO{k};
    
    
    % nonlinear optimization with RoNIN IO drift correction model
    [RoninIO] = optimizeEachRoninIOwithScaleBias(RoninIO);
    datasetRoninIO{k} = RoninIO;
end


%% temporary codes for WiFi similarity visualization

k = 1;

% current RoNIN IO data
RoninIO = datasetRoninIO{k};
numRoninIO = size(RoninIO,2);
testWiFiScanResult = struct('timestamp',cell(1,numRoninIO),'RSSI',cell(1,numRoninIO),'trueLocation',cell(1,numRoninIO));
numCount = 0;
for m = 1:numRoninIO
    
    % check WiFi scan RSSI exist or not
    if (~isempty(RoninIO(m).RSSI))
        
        numCount = numCount + 1;
        testWiFiScanResult(numCount).timestamp = RoninIO(m).timestamp;
        testWiFiScanResult(numCount).RSSI = RoninIO(m).RSSI;
        testWiFiScanResult(numCount).trueLocation = RoninIO(m).location;
    end
end
testWiFiScanResult((numCount+1):end) = [];


testRoninIndex = [8 9 16 26 27 39 40 48];

% construct WiFi fingerprint database
wifiFingerprintDatabase = [];
for k = testRoninIndex
    
    % current RoNIN IO data
    RoninIO = datasetRoninIO{k};
    numRoninIO = size(RoninIO,2);
    tempWiFiScanResult = struct('timestamp',cell(1,numRoninIO),'RSSI',cell(1,numRoninIO),'trueLocation',cell(1,numRoninIO));
    numCount = 0;
    for m = 1:numRoninIO
        
        % check WiFi scan RSSI exist or not
        if (~isempty(RoninIO(m).RSSI))
            
            numCount = numCount + 1;
            tempWiFiScanResult(numCount).timestamp = RoninIO(m).timestamp;
            tempWiFiScanResult(numCount).RSSI = RoninIO(m).RSSI;
            tempWiFiScanResult(numCount).trueLocation = RoninIO(m).location;
        end
    end
    tempWiFiScanResult((numCount+1):end) = [];
    
    
    % save WiFi scan results
    wifiFingerprintDatabase = [wifiFingerprintDatabase, tempWiFiScanResult];
end


numTestWiFiScan = size(testWiFiScanResult,2);
for queryIndex = 1:numTestWiFiScan
    
    % current RSSI vector and true position from RoNIN IO
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















