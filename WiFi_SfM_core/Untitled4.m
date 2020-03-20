clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;

addpath('devkit_KITTI_GPS');


%% Tango VIO / Google FLP visualization

% multiple dataset path
datasetPath = 'G:\Google Drive\3_SFU_Postdoc____2019_2021\Smartphone_Dataset\4_WiFi_SfM\Asus_Tango\SFU_Multiple_Buildings_withVIO';
datasetList = dir(datasetPath);
datasetList(1:2) = [];


% load Tango VIO / Google FLP result
numDatasetList = size(datasetList,1);
datasetTangoPoseResult = cell(1,numDatasetList);
for k = 1:15
    
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


for k = 16:17
    
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



%%

% plot Tango VIO trajectories
distinguishableColors = distinguishable_colors(numDatasetList);
figure;
for k = 1:numDatasetList
    
    % Tango VIO data
    TangoPoseResult = datasetTangoPoseResult{k};
    TangoXYLocation = [TangoPoseResult.stateEsti_Tango];
    TangoXYLocation = TangoXYLocation(1:2,:);
    
    
    % plot Tango VIO data
    subplot(3,5,k);
    plot(TangoXYLocation(1,:),TangoXYLocation(2,:),'color',distinguishableColors(k,:),'LineWidth',1.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    title(sprintf('Tango VIO Index: %02d',k));
end
set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure
