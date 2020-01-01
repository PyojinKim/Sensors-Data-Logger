


addpath('devkit_KITTI_GPS');


GoogleFLPResult = parseGoogleFLPTextFile('FLP.txt');



temp = [GoogleFLPResult(:).locationMeter];


figure;
plot(temp(1,:),temp(2,:),'k*-'); grid on;



%% 1) plot all Tango VIO pose in global inertial frame

% initialize various colors for figures
distinguishableColors = distinguishable_colors(numDatasetList);


% plot Tango VIO motion estimation results
figure; hold on; grid on;
for k = 1:numDatasetList
    TangoPose = [datasetTangoPoseResult{k}.stateEsti_Tango];
    plot3(TangoPose(1,:),TangoPose(2,:),TangoPose(3,:),'color',distinguishableColors(k,:),'LineWidth',2);
end
plot_inertial_frame(0.5); axis equal; view(0,90);
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); zlabel('z [m]','fontsize',10); hold off;

% figure options
f = FigureRotator(gca());


%% 2) plot all labeled WiFi scan locations from Tango VIO location

% plot labeled WiFi scan locations
figure; hold on; grid on;
for k = 1:numDatasetList
    wifiScanLocation = [datasetWiFiScanResult{k}.location];
    plot3(wifiScanLocation(1,:),wifiScanLocation(2,:),wifiScanLocation(3,:),'color',distinguishableColors(k,:),'LineWidth',2);
end
plot_inertial_frame(0.5); axis equal; view(0,90);
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); zlabel('z [m]','fontsize',10); hold off;

% figure options
f = FigureRotator(gca());


%%

wifiScanLocation = [labeledWiFiScanRSSI.location];

% plot labeled WiFi scan locations
figure;
plot3(wifiScanLocation(1,:),wifiScanLocation(2,:),wifiScanLocation(3,:),'ko','LineWidth',2); hold on; grid on;
plot_inertial_frame(0.5); axis equal; view(0,90);
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); zlabel('z [m]','fontsize',10); hold off;

% figure options
f = FigureRotator(gca());


%%

close all;
bar(wifiScanRSSI(45).RSSI)
xlabel('unique AP ID','fontsize',10); ylabel('RSSI (dBm)','fontsize',10);


%%

%
wifiTime = [wifiScanRSSI.timestamp].';
poseTime = [TangoPoseResult.timestamp].';


% define reference time and data
startTime = max([poseTime(1), wifiTime(1)]);
poseTime = poseTime - startTime;
wifiTime = wifiTime - startTime;
endTime = max([poseTime(end), wifiTime(end)]);

timeInterval = 0.01;
syncTimestamp = [0.001:timeInterval:endTime];
numData = size(syncTimestamp,2);


% synchronize Tango, WiFi RSSI vector
syncWiFiRSSI = cell(1,numData);
syncWiFiRSSI_index = [];
syncTangoPose = cell(1,numData);
syncTangoTrajectory = zeros(6,numData);
for k = 1:numData
    
    % remove future timestamp
    currentTime = syncTimestamp(k);
    validIndexWiFi = ((currentTime - wifiTime) > 0);
    validIndexTango = ((currentTime - poseTime) > 0);
    timestampWiFi = wifiTime(validIndexWiFi);
    timestampTango = poseTime(validIndexTango);
    
    
    % WiFi RSSI
    [timeDifference, indexWiFi] = min(abs(currentTime - timestampWiFi));
    if (timeDifference <= timeInterval)
        syncWiFiRSSI{k} = wifiScanRSSI(indexWiFi).RSSI;
        syncWiFiRSSI_index = [syncWiFiRSSI_index, k];
    end
    
    
    % Tango
    [timeDifference, indexTango] = min(abs(currentTime - timestampTango));
    syncTangoPose{k} = TangoPoseResult(indexTango).T_gb_Tango;
    syncTangoTrajectory(:,k) = TangoPoseResult(indexTango).stateEsti_Tango;
    
    
    % display current status
    fprintf('Current Status: %d / %d \n', k, numData);
end




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

%%


load('test_matlab.csv');

% colorize by Z coordinate
X = test_matlab(:,1);
Y = test_matlab(:,2);
Z = test_matlab(:,3);
C = Z;

scatter3(X(:),Y(:),Z(:),5,C(:),'.');

colormap(jet);
colorbar;

xlabel('X Coordinate');
ylabel('Y Coordinate');
zlabel('Height above sea level');



% accumulate labeled WiFi RSSI vector
labeledWiFiScanRSSI = [];
numDataset = size(datasetWiFiScanResult,2);
for k = 2:numDataset
    labeledWiFiScanRSSI = [labeledWiFiScanRSSI, datasetWiFiScanResult{k}];
end

errorDistance = zeros(1,78);
for queryIndex = 1:78
    
    % choose query RSSI vector
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
        if ((distanceCount ~= 0) && (distanceCount > 15))
            %distanceResult(k) = sqrt(distanceSum / distanceCount);   % L2 distance
            distanceResult(k) = distanceSum / distanceCount;             % L1 distance
        end
    end
    
    %
    [~,index] = min(distanceResult);
    errorDistance(queryIndex) = norm(datasetWiFiScanResult{1}(queryIndex).location - labeledWiFiScanRSSI(index).location);
end

figure;
plot(errorDistance); grid on; axis tight;
xlabel('WiFi Scan Location Index'); ylabel('Error Distance (m)');

