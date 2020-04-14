

% optimized Tango VIO visualization
k = 2

% current Tango VIO data
TangoVIO = datasetTangoVIO{k};
TangoVIOLocation = [TangoVIO.location];


% plot Tango VIO location
distinguishableColors = distinguishable_colors(numDatasetList);
figure(10); hold on; grid on; axis equal; axis tight;
plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'-','color','b','LineWidth',1.5); grid on; axis equal;


for m = 1:size(TangoVIO,2)
    if (~isempty(TangoVIO(m).FLPLocationMeter))
        
        location = TangoVIO(m).location;
        center = TangoVIO(m).FLPLocationMeter;
        radius = TangoVIO(m).FLPAccuracyMeter;
        
        theta = [0:pi/50:2*pi];
        x_circle = center(1) + radius * cos(theta);
        y_circle = center(2) + radius * sin(theta);
        plot(x_circle, y_circle,'color','m','LineWidth',1.0);
        
        plot([location(1) center(1)],[location(2) center(2)],'color','r','LineWidth',4.0);
    end
end


xlabel('X [m]','FontName','Times New Roman','FontSize',15);
ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure



%% WiFi localization heat map video clip

% create figure frame for making video
h_WiFi = figure(10);
set(h_WiFi,'Color',[1 1 1]);
set(h_WiFi,'Units','pixels','Position',[100 100 1800 850]);
ha1 = axes('Position',[0.02,0.05 , 0.60,0.90]); % [x_start, y_start, x_width, y_width]
ha2 = axes('Position',[0.68,0.25 , 0.30,0.50]); % [x_start, y_start, x_width, y_width]
for queryIdx = 1:numTestWiFiScan
    %% prerequisite to visualize
    
    % re-arrange WiFi scan location
    maxRewardIndex = testWiFiScanResult(queryIdx).maxRewardIndex;
    rewardResult = testWiFiScanResult(queryIdx).rewardResult;
    errorLocation = testWiFiScanResult(queryIdx).errorLocation;
    
    databaseWiFiScanLocation = [wifiFingerprintDatabase(:).trueLocation];
    trueLocation = testWiFiScanResult(queryIdx).trueLocation;
    maxRewardWiFiScanLocation = [wifiFingerprintDatabase(maxRewardIndex).trueLocation];
    
    
    %% update WiFi scan location with distance (reward function) heat map
    
    axes(ha1); cla;
    scatter(databaseWiFiScanLocation(1,:),databaseWiFiScanLocation(2,:),100,rewardResult,'.'); hold on; grid on;
    plot(trueLocation(1),trueLocation(2),'kd','LineWidth',3);
    plot(maxRewardWiFiScanLocation(1,:),maxRewardWiFiScanLocation(2,:),'md','LineWidth',3);
    colormap(jet); colorbar;
    xlabel('X [m]'); ylabel('Y [m]'); axis equal; axis tight;
    
    text(-80, 50, 0, sprintf('Location Error (m): %2.2f', errorLocation),'Color','k','FontSize',11,'FontWeight','bold');
    
    
    %% update reward metric result
    
    axes(ha2); cla;
    plot(rewardResult); grid on; axis tight;
    xlabel('WiFi Scan Location Index in Fingerprint Database'); ylabel('Reward Metric');
    
    
    % save images
    pause(0.01); refresh;
    saveImg = getframe(h_WiFi);
    imwrite(saveImg.cdata , sprintf('figures/%06d.png', queryIdx));
end


%%

% Tango VIO data
TangoVIOLocation = [TangoVIO.location];

% Google FLP data
GoogleFLPLocationMeter = [TangoVIO.FLPLocationMeter];
GoogleFLPLocationDegree = [TangoVIO.FLPLocationDegree];
GoogleFLPAccuracyMeter = [TangoVIO.FLPAccuracyMeter];


% plot
figure;
subplot(1,3,1);
plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'k-','LineWidth',1.5); grid on; axis equal; axis tight;
xlabel('X [m]','FontName','Times New Roman','FontSize',15);
ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
title('Tango VIO History');
subplot(1,3,2);
plot(GoogleFLPLocationMeter(1,:),GoogleFLPLocationMeter(2,:),'k*-','LineWidth',1.5); grid on; axis equal; axis tight;
xlabel('X [m]','FontName','Times New Roman','FontSize',15);
ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
title('Google FLP History (m)');
subplot(1,3,3); hold on;
plot(GoogleFLPLocationDegree(2,:), GoogleFLPLocationDegree(1,:),'*-','color','k','LineWidth',1.0);
%plot_Google_FLP_Accuracy_Radius(GoogleFLPLocationDegree, GoogleFLPAccuracyMeter, 'k', 0.1);
plot_google_map('maptype', 'roadmap', 'APIKey', 'AIzaSyB_uD1rGjX6MJkoQgSDyjHkbdu-b-_5Bjg');
xlabel('Longitude [deg]','FontName','Times New Roman','FontSize',15);
ylabel('Latitude [deg]','FontName','Times New Roman','FontSize',15);
set(gcf,'Units','pixels','Position',[150 300 1700 600]);  % modify figure


%% Tango VIO / Google FLP visualization

% multiple dataset path
datasetPath = 'G:\Google Drive\3_SFU_Postdoc____2019_2021\Smartphone_Dataset\4_WiFi_SfM\Asus_Tango\SFU_Multiple_Buildings_withVIO';
datasetList = dir(datasetPath);
datasetList(1:2) = [];


% load Tango VIO / Google FLP result
numDatasetList = size(datasetList,1);
datasetTangoPoseResult = cell(1,numDatasetList);
for k = 1:numDatasetList
    
    % read manual alignment result
    expCase = k;
    manual_alignment_Asus_Tango_SFU_Multiple_Buildings;
    R = angle2rotmtx([0;0;(deg2rad(yaw))]);
    t = [tx; ty];
    
    
    % parse pose.txt
    datasetDirectory = [datasetPath '\' datasetList(k).name];
    TangoVIOInterval = 50;
    accuracyThreshold = 25;
    TangoVIO = extractTangoVIOCentricData(datasetDirectory, TangoVIOInterval, accuracyThreshold);
    TangoVIOLocation = [TangoVIO.location];
    TangoVIOLocation = R(1:2,1:2) * TangoVIOLocation + t;
    
    
    expCase
    TangoVIOLocation(:,end)
    
    
    % plot Tango VIO location
    distinguishableColors = distinguishable_colors(numDatasetList);
    figure(10); hold on; grid on; axis equal; axis tight;
    plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'color',distinguishableColors(k,:),'LineWidth',1.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure
end


%% WiFi localization heat map figure

% create figure frame for making video
h_WiFi = figure(10);
set(h_WiFi,'Color',[1 1 1]);
set(h_WiFi,'Units','pixels','Position',[100 50 1800 900]);
ha1 = axes('Position',[0.02,0.05 , 0.60,0.90]); % [x_start, y_start, x_width, y_width]
ha2 = axes('Position',[0.68,0.25 , 0.30,0.50]); % [x_start, y_start, x_width, y_width]
for queryIdx = 1:numTestWiFiScan
    %% prerequisite to visualize
    
    % re-arrange WiFi scan location
    maxRewardIndex = testWiFiScanResult(queryIdx).maxRewardIndex;
    rewardResult = testWiFiScanResult(queryIdx).rewardResult;
    errorLocation = testWiFiScanResult(queryIdx).errorLocation;
    
    databaseWiFiScanLocation = [wifiFingerprintDatabase(:).trueLocation];
    trueLocation = testWiFiScanResult(queryIdx).trueLocation;
    maxRewardWiFiScanLocation = [wifiFingerprintDatabase(maxRewardIndex).trueLocation];
    
    
    %% update WiFi scan location with distance (reward function) heat map
    
    axes(ha1); cla;
    scatter3(databaseWiFiScanLocation(1,:),databaseWiFiScanLocation(2,:),databaseWiFiScanLocation(3,:),100,rewardResult,'.'); hold on; grid on;
    plot3(trueLocation(1),trueLocation(2),trueLocation(3)+0.5,'kd','LineWidth',3);
    plot3(maxRewardWiFiScanLocation(1,:),maxRewardWiFiScanLocation(2,:),maxRewardWiFiScanLocation(3,:)+0.5,'md','LineWidth',3);
    colormap(jet); colorbar;
    plot_inertial_frame(0.5); axis equal; view(158,47);
    xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
    
    text(-10, -20, 0, sprintf('location error (m): %2.2f', errorLocation),'Color','k','FontSize',11,'FontWeight','bold');
    
    
    %% update reward metric result
    
    axes(ha2); cla;
    plot(rewardResult); grid on; axis tight;
    xlabel('WiFi Scan Location Index in Fingerprint Database'); ylabel('Reward Metric');
    
    
    % save images
    pause(0.01); refresh;
    saveImg = getframe(h_WiFi);
    imwrite(saveImg.cdata , sprintf('figures/%06d.png', queryIdx));
end


%% make .avi file from png files

movie = VideoWriter('myAVI.avi');
movie.FrameRate = 2; % set fps
open(movie);

for queryIdx = 1:numTestWiFiScan
    
    % read PNG image file
    filename = sprintf('figures/%06d.png', queryIdx);
    im = imread(filename);
    
    % write video
    writeVideo(movie, im);
    
    queryIdx
end

close(movie);


%%

clear x y
HuberParameter = 10;
x = 0:0.01:100;

for i = 1:length(x)
    y(i) = HuberFunction(x(i), HuberParameter);
end

figure;
plot(x,y,'k','LineWidth',2.5); grid on; axis tight;
xlabel('X - RSSI Value Difference'); ylabel('f(X) - the Huber function');


clear x y
TukeyParameter = 160;
x = 0:0.01:170;

for i = 1:length(x)
    y(i) = TukeyFunction(x(i), TukeyParameter);
end

figure;
plot(x,y,'k','LineWidth',2.5); grid on; axis tight;
xlabel('X - Average RSSI Value'); ylabel('g(X) - the Tukey function');




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

% initialize various colors for figures
distinguishableColors = distinguishable_colors(numDatasetList);


% plot labeled WiFi scan locations
figure; hold on; grid on;
for k = 1:numDatasetList
    wifiScanLocation = [datasetWiFiScanResult{k}.trueLocation];
    plot3(wifiScanLocation(1,:),wifiScanLocation(2,:),wifiScanLocation(3,:),'d','color',distinguishableColors(k,:),'LineWidth',2);
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

