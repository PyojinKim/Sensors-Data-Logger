clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;

addpath('devkit_KITTI_GPS');


%% 1) load Tango VIO data

% multiple dataset path
datasetPath = 'G:\Google Drive\3_SFU_Postdoc____2019_2021\Smartphone_Dataset\4_WiFi_SfM\Asus_Tango\SFU_Multiple_Buildings_withVIO';
datasetList = dir(datasetPath);
datasetList(1:2) = [];


% load Tango VIO data
numDatasetList = 8; %size(datasetList,1);
datasetTangoVIO = cell(1,numDatasetList);
for k = 1:numDatasetList
    
    % parse pose.txt / FLP.txt
    datasetDirectory = [datasetPath '\' datasetList(k).name];
    TangoVIOInterval = 100;   % 200 Hz
    accuracyThreshold = 25;   % in meter
    TangoVIO = extractTangoVIOCentricData(datasetDirectory, TangoVIOInterval, accuracyThreshold);
    
    
    % save Tango VIO
    datasetTangoVIO{k} = TangoVIO;
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


%% 2) optimize each Tango VIO against Google FLP

%
for k = 1:numDatasetList
    
    % current Tango VIO data
    TangoVIO = datasetTangoVIO{k};
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
    plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'*-','color',distinguishableColors(k,:),'LineWidth',1.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure
end


%% 3) optimize each Tango VIO against Google FLP






























