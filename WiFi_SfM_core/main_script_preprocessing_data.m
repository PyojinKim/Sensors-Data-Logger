clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;


%% 1) manual Tango VIO alignment for global (consistent) inertial frame

% parse pose.txt file (from ASUS Tango)
[TangoPoseReference] = parseTangoPoseTextFile('pose_reference.txt');
[TangoPoseTest] = parseTangoPoseTextFile('pose_test.txt');
poseReference = [TangoPoseReference(:).stateEsti_Tango];
poseTest = [TangoPoseTest(:).stateEsti_Tango];


% find yaw / translation x-y-z
yaw = 183.5;
tx = -0.0;
ty = 1.5;
tz = 0;


% manual coordinate alignment (global inertial frame)
R = angle2rotmtx([0;0;(deg2rad(yaw))]);
t = [tx; ty; tz];


% transform Tango VIO trajectory
poseTestTransformed = R * poseTest(1:3,:);
poseTestTransformed = poseTestTransformed + t;


% plot Tango VIO motion estimation results
figure;
plot3(poseReference(1,:),poseReference(2,:),poseReference(3,:),'k','LineWidth',2); hold on; grid on;
plot3(poseTestTransformed(1,:),poseTestTransformed(2,:),poseTestTransformed(3,:),'r','LineWidth',2);
plot_inertial_frame(0.5); axis equal; view(0, 90);
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); zlabel('z [m]','fontsize',10); hold off;


%% 2) build unique BSSID map for RSSI vectorization

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


% extract all recorded WiFi BSSID
tempWiFiAPsBSSID = [];
for k = 1:numDatasetList
    
    % current WiFi scan result
    currentWiFiScanResult = datasetWiFiScanResult{k};
    numWiFiScan = size(currentWiFiScanResult,2);
    for m = 1:numWiFiScan
        
        % current number of APs
        numWiFiAPs = currentWiFiScanResult(m).numberOfAPs;
        for n = 1:numWiFiAPs
            
            % save current WiFi BSSID
            currentBSSID = convertCharsToStrings(currentWiFiScanResult(m).wifiAPsResult(n).BSSID);
            tempWiFiAPsBSSID = [tempWiFiAPsBSSID; currentBSSID];
        end
    end
end


% find unique WiFi BSSID
uniqueWiFiAPsBSSID = unique(tempWiFiAPsBSSID);
numUniqueBSSID = size(uniqueWiFiAPsBSSID,1);


% save unique WiFi BSSID list (WiFi BSSID Map)
save('uniqueWiFiAPsBSSID.mat','uniqueWiFiAPsBSSID');



