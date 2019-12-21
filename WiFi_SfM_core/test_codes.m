

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




%%

%
poseReference = [datasetTangoPoseResult{1}.stateEsti_Tango];
pose2= [datasetTangoPoseResult{2}.stateEsti_Tango];
pose3= [datasetTangoPoseResult{3}.stateEsti_Tango];
pose4= [datasetTangoPoseResult{4}.stateEsti_Tango];
pose5= [datasetTangoPoseResult{5}.stateEsti_Tango];
pose6= [datasetTangoPoseResult{6}.stateEsti_Tango];
pose7= [datasetTangoPoseResult{7}.stateEsti_Tango];

% plot Tango VIO motion estimation results
figure;
plot3(poseReference(1,:),poseReference(2,:),poseReference(3,:),'k','LineWidth',2); hold on; grid on;
plot3(pose2(1,:),pose2(2,:),pose2(3,:),'k','LineWidth',2);
plot3(pose3(1,:),pose3(2,:),pose3(3,:),'k','LineWidth',2);
plot3(pose4(1,:),pose4(2,:),pose4(3,:),'k','LineWidth',2);
plot3(pose5(1,:),pose5(2,:),pose5(3,:),'k','LineWidth',2);
plot3(pose6(1,:),pose6(2,:),pose6(3,:),'k','LineWidth',2);
plot3(pose7(1,:),pose7(2,:),pose7(3,:),'k','LineWidth',2);
plot_inertial_frame(0.5); axis equal; view(0,90);
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); zlabel('z [m]','fontsize',10);


plot3(datasetWiFiScanResult{1}(queryIndex).location(1),...
    datasetWiFiScanResult{1}(queryIndex).location(2),...
    datasetWiFiScanResult{1}(queryIndex).location(3),'ro','LineWidth',3);

plot3(labeledWiFiScanRSSI(index).location(1),...
    labeledWiFiScanRSSI(index).location(2),...
    labeledWiFiScanRSSI(index).location(3),'bo','LineWidth',5);

hold off;


norm(datasetWiFiScanResult{1}(queryIndex).location - labeledWiFiScanRSSI(index).location)


















%%

%
poseReference = [datasetTangoPoseResult{1}.stateEsti_Tango];
pose2= [datasetTangoPoseResult{2}.stateEsti_Tango];
pose3= [datasetTangoPoseResult{3}.stateEsti_Tango];
pose4= [datasetTangoPoseResult{4}.stateEsti_Tango];
pose5= [datasetTangoPoseResult{5}.stateEsti_Tango];
pose6= [datasetTangoPoseResult{6}.stateEsti_Tango];
pose7= [datasetTangoPoseResult{7}.stateEsti_Tango];

% plot Tango VIO motion estimation results
figure;
plot3(poseReference(1,:),poseReference(2,:),poseReference(3,:),'k','LineWidth',2); hold on; grid on;
plot3(pose2(1,:),pose2(2,:),pose2(3,:),'r','LineWidth',2);
plot3(pose3(1,:),pose3(2,:),pose3(3,:),'g','LineWidth',2);
plot3(pose4(1,:),pose4(2,:),pose4(3,:),'b','LineWidth',2);
plot3(pose5(1,:),pose5(2,:),pose5(3,:),'m','LineWidth',2);
plot3(pose6(1,:),pose6(2,:),pose6(3,:),'c','LineWidth',2);
plot3(pose7(1,:),pose7(2,:),pose7(3,:),'y','LineWidth',2);
plot_inertial_frame(0.5); axis equal; view(0,90);
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); zlabel('z [m]','fontsize',10); hold off;

% figure options
f = FigureRotator(gca());


%%

wifiScanLocation1 = [datasetWiFiScanResult{1}.location];
wifiScanLocation2 = [datasetWiFiScanResult{2}.location];
wifiScanLocation3 = [datasetWiFiScanResult{3}.location];
wifiScanLocation4 = [datasetWiFiScanResult{4}.location];
wifiScanLocation5 = [datasetWiFiScanResult{5}.location];
wifiScanLocation6 = [datasetWiFiScanResult{6}.location];
wifiScanLocation7 = [datasetWiFiScanResult{7}.location];

% plot labeled WiFi scan locations
figure;
plot3(wifiScanLocation1(1,:),wifiScanLocation1(2,:),wifiScanLocation1(3,:),'ko','LineWidth',2); hold on; grid on;
plot3(wifiScanLocation2(1,:),wifiScanLocation2(2,:),wifiScanLocation2(3,:),'ro','LineWidth',2);
plot3(wifiScanLocation3(1,:),wifiScanLocation3(2,:),wifiScanLocation3(3,:),'go','LineWidth',2);
plot3(wifiScanLocation4(1,:),wifiScanLocation4(2,:),wifiScanLocation4(3,:),'bo','LineWidth',2);
plot3(wifiScanLocation5(1,:),wifiScanLocation5(2,:),wifiScanLocation5(3,:),'mo','LineWidth',2);
plot3(wifiScanLocation6(1,:),wifiScanLocation6(2,:),wifiScanLocation6(3,:),'co','LineWidth',2);
plot3(wifiScanLocation7(1,:),wifiScanLocation7(2,:),wifiScanLocation7(3,:),'yo','LineWidth',2);
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









