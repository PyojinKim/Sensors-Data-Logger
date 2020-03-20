clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;

addpath('devkit_KITTI_GPS');


%% Tango VIO / Google FLP visualization

% multiple dataset path
datasetPath = 'G:\Google Drive\3_SFU_Postdoc____2019_2021\Smartphone_Dataset\4_WiFi_SfM\Samsung_Galaxy_S9\SFU_Multiple_Buildings';
datasetList = dir(datasetPath);
datasetList(1:2) = [];


% parse pose.txt / FLP.txt file
k = 17;
datasetDirectory = [datasetPath '\' datasetList(k).name];
GoogleFLPResult = parseGoogleFLPTextFile([datasetDirectory '\FLP.txt']);


% refine valid Google FLP with accuracy
GoogleFLPAccuracy = [GoogleFLPResult.accuracyMeter];
GoogleFLPIndex = (GoogleFLPAccuracy < 25.0);
GoogleFLPResult = GoogleFLPResult(GoogleFLPIndex);


% Google FLP data
GoogleFLPLocationMeter = [GoogleFLPResult.locationMeter];
GoogleFLPLocationDegree = [GoogleFLPResult.locationDegree];
GoogleFLPAccuracyMeter = [GoogleFLPResult.accuracyMeter];


% plot
figure;
subplot(1,2,1);
plot(GoogleFLPLocationMeter(1,:),GoogleFLPLocationMeter(2,:),'k*-','LineWidth',1.5); grid on; axis equal; axis tight;
xlabel('X [m]','FontName','Times New Roman','FontSize',15);
ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
title('Google FLP History (m)');
subplot(1,2,2); hold on;
plot(GoogleFLPLocationDegree(2,:), GoogleFLPLocationDegree(1,:),'*-','color','k','LineWidth',1.0);
%plot_Google_FLP_Accuracy_Radius(GoogleFLPLocationDegree, GoogleFLPAccuracyMeter, 'k', 0.1);
plot_google_map('maptype', 'roadmap', 'APIKey', 'AIzaSyB_uD1rGjX6MJkoQgSDyjHkbdu-b-_5Bjg');
xlabel('Longitude [deg]','FontName','Times New Roman','FontSize',15);
ylabel('Latitude [deg]','FontName','Times New Roman','FontSize',15);
set(gcf,'Units','pixels','Position',[150 300 1700 600]);  % modify figure











