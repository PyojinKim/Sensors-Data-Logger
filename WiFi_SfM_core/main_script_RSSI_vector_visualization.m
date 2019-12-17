clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;


%% common setting to read text files

delimiter = ' ';
headerlinesIn = 1;
nanoSecondToSecond = 1000000000;


%% 1)

% parse wifi.txt file
[wifiScanResult] = parseWiFiTextFile('wifi.txt');


% vectorize WiFi RSSI for each WiFi scan
[wifiScanRSSI,~] = vectorizeWiFiRSSI(wifiScanResult);


% parse pose.txt file (from ASUS Tango)
[TangoPoseResult] = parseTangoPoseTextFile('pose.txt');





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

m = syncWiFiRSSI_index(25);
plot3(syncTangoTrajectory(1,m),syncTangoTrajectory(2,m),syncTangoTrajectory(3,m),'ro','LineWidth',5);

m = syncWiFiRSSI_index(45);
plot3(syncTangoTrajectory(1,m),syncTangoTrajectory(2,m),syncTangoTrajectory(3,m),'ro','LineWidth',5);



for m = syncWiFiRSSI_index
    
    plot3(syncTangoTrajectory(1,m),syncTangoTrajectory(2,m),syncTangoTrajectory(3,m),'ro','LineWidth',5);
    m
    
end


hold off;

% figure options
f = FigureRotator(gca());



close all;
bar(wifiScanRSSI(45).RSSI)
xlabel('unique AP ID','fontsize',10); ylabel('RSSI (dBm)','fontsize',10);














