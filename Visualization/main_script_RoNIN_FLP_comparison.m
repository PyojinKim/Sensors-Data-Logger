clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;

addpath('devkit_KITTI_GPS');


%% common setting to read text files

delimiter = ' ';
headerlinesIn = 1;
nanoSecondToSecond = 1000000000;


%% pre-processing RoNIN, Google FLP on lat/lon

% define start position by Google Map manually..
startPositionDegree = [49.250913, -122.895135];
[startPositionMeter, scale] = degreeToMeter(startPositionDegree);


% parse RoNIN pose text file
[RoninPoseDegree, RoninPoseTime] = importRoninTextFile('ronin.txt', -9, startPositionMeter, scale);

% plot horizontal position (latitude / longitude) trajectory on Google map
figure;
plot(RoninPoseDegree(2,:), RoninPoseDegree(1,:), 'm', 'LineWidth', 1); hold on;
plot_google_map('maptype', 'roadmap', 'APIKey', 'AIzaSyB_uD1rGjX6MJkoQgSDyjHkbdu-b-_5Bjg');
xlabel('Longitude [deg]','FontName','Times New Roman','FontSize',17);
ylabel('Latitude [deg]','FontName','Times New Roman','FontSize',17);


% parse Google FLP text file
[FLPPoseDegree, FLPPoseTime, FLPPoseMeter, FLPAccuracyMeter] = importGoogleFLPTextFile('FLP.txt');
scale = latToScale(FLPPoseDegree(1,1));

% plot horizontal position (latitude / longitude) trajectory on Google map
figure;
plot(FLPPoseDegree(2,:), FLPPoseDegree(1,:), 'b*-', 'LineWidth', 1); hold on;
plot_google_map('maptype', 'roadmap', 'APIKey', 'AIzaSyB_uD1rGjX6MJkoQgSDyjHkbdu-b-_5Bjg');
xlabel('Longitude [deg]','FontName','Times New Roman','FontSize',17);
ylabel('Latitude [deg]','FontName','Times New Roman','FontSize',17);


% re-arrange RoNIN, FLP variables
rawDeviceDataset.RoninPoseTime = RoninPoseTime;
rawDeviceDataset.RoninPoseDegree = RoninPoseDegree;
rawDeviceDataset.FLPPoseTime = FLPPoseTime;
rawDeviceDataset.FLPPoseDegree = FLPPoseDegree;
rawDeviceDataset.FLPPoseMeter = FLPPoseMeter;
rawDeviceDataset.FLPAccuracyMeter = FLPAccuracyMeter;


% synchronize RoNIN, Google FLP
[deviceDataset] = synchronizeRoNIN_FLP(rawDeviceDataset, 0.5);
syncTimestamp = deviceDataset.syncTimestamp;
syncRoninPoseDegree = deviceDataset.syncRoninPoseDegree;
syncFLPPoseDegree = deviceDataset.syncFLPPoseDegree;
syncFLPPoseMeter = deviceDataset.syncFLPPoseMeter;
syncFLPAccuracyMeter = deviceDataset.syncFLPAccuracyMeter;
numData = size(syncRoninPoseDegree,2);


%% RoNIN, Google FLP video clip

% plot horizontal position (latitude / longitude) trajectory on Google map
h = figure(10);
plot_google_map('maptype', 'roadmap', 'APIKey', 'AIzaSyB_uD1rGjX6MJkoQgSDyjHkbdu-b-_5Bjg'); hold on;
xlabel('Longitude [deg]','FontName','Times New Roman','FontSize',17);
ylabel('Latitude [deg]','FontName','Times New Roman','FontSize',17);

axis([-122.8967 -122.8944   49.2504   49.2518]) % 20191111_02_Lougheed_Mall_Galaxy_S9
%axis([-122.8968 -122.8943   49.2506   49.2521]) % 20191111_03_Lougheed_Mall_Galaxy_S9
%axis([-122.8946 -122.8928   49.2518   49.2531]) % 20191117_01_Save_On_Foods
%axis([127.0570  127.0617   37.5100   37.5135]) % 20191031_02_COEX_Seoul_Galaxy_S9
%axis([-122.9217 -122.9083   49.2747   49.2808]) % 20191004_05_SFU_Home_Galaxy_S9

set(gcf,'Units','pixels','Position',[400 200 1000 700]);  % modify figure


for k = 1:numData
    %% prerequisite to visualize
    
    % plot RoNIN trajectory
    h_RoNIN_history = plot(syncRoninPoseDegree(2,1:k), syncRoninPoseDegree(1,1:k),'m','LineWidth',2);
    h_RoNIN_location = plot(syncRoninPoseDegree(2,k), syncRoninPoseDegree(1,k),'mo','LineWidth',5);
    
    % plot Google FLP trajectory
    h_FLP_history = plot(syncFLPPoseDegree(2,1:k), syncFLPPoseDegree(1,1:k),'b*-','LineWidth',1);
    h_FLP_location = plot(syncFLPPoseDegree(2,k), syncFLPPoseDegree(1,k),'bo','LineWidth',5);
    
    % plot Google FLP uncertainty radius
    [lon, lat] = convertAccuracyDegree(syncFLPPoseMeter(1,k), syncFLPPoseMeter(2,k), syncFLPAccuracyMeter(k), scale);
    h_FLP_radius = plot(lon, lat, 'b','LineWidth',3);
    
    % plot FLP text information
    currentTime = syncTimestamp(k);
    currentLatitude = syncFLPPoseDegree(1,k);
    currentLongitude = syncFLPPoseDegree(2,k);
    xt = [currentLongitude+0.00010, currentLongitude+0.00010];
    yt = [currentLatitude+0.00015, currentLatitude+0.00010];
    str = {sprintf('time (s): %.2f', currentTime),sprintf('uncertainty (m): %.2f', syncFLPAccuracyMeter(k))};
    h_FLP_text = text(xt, yt, str,'FontSize',15,'FontWeight','bold');
    
    
    %% save current figure
    
    if (true)
        % save directory for MAT data
        SaveDir = [pwd '\temp'];
        if (~exist( SaveDir, 'dir' ))
            mkdir(SaveDir);
        end
        
        % save directory for images
        SaveImDir = [SaveDir '\FLP'];
        if (~exist( SaveImDir, 'dir' ))
            mkdir(SaveImDir);
        end
        
        refresh; pause(0.001);
        saveImg = getframe(h);
        imwrite(saveImg.cdata , [SaveImDir sprintf('/%06d.png', k)]);
    end
    
    %% remove existing plots
    
    delete(h_RoNIN_history)
    delete(h_RoNIN_location)
    
    delete(h_FLP_history);
    delete(h_FLP_location);
    delete(h_FLP_radius);
    delete(h_FLP_text);
end


