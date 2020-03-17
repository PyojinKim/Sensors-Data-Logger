clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;

addpath('devkit_KITTI_GPS');


%% Google FLP visualization

% multiple dataset path
datasetPath = 'G:\Google Drive\3_SFU_Postdoc____2019_2021\Smartphone_Dataset\4_WiFi_SfM\Asus_Tango\SFU_Multiple_Buildings_withVIO';
datasetList = dir(datasetPath);
datasetList(1:2) = [];


% load Google FLP result
numDatasetList = size(datasetList,1);
datasetGoogleFLPResult = cell(1,numDatasetList);
for k = 1:numDatasetList
    
    % parse FLP.txt file
    datasetDirectory = [datasetPath '\' datasetList(k).name];
    GoogleFLPResult = parseGoogleFLPTextFile([datasetDirectory '\FLP.txt']);
    
    
    % refine valid Google FLP with accuracy
    GoogleFLPAccuracy = [GoogleFLPResult.accuracyMeter];
    GoogleFLPIndex = (GoogleFLPAccuracy < 25.0);
    GoogleFLPResult = GoogleFLPResult(GoogleFLPIndex);
    
    
    % save Google FLP result
    datasetGoogleFLPResult{k} = GoogleFLPResult;
end


% plot multiple Google FLP results on Google Map
distinguishableColors = distinguishable_colors(numDatasetList);
figure; hold on;
for k = 1:numDatasetList
    
    % Google FLP data
    GoogleFLPResult = datasetGoogleFLPResult{k};
    GoogleFLPLocationDegree = [GoogleFLPResult.locationDegree];
    GoogleFLPAccuracyMeter = [GoogleFLPResult.accuracyMeter];
    
    
    % plot Google FLP data
    plot(GoogleFLPLocationDegree(2,:), GoogleFLPLocationDegree(1,:),'*-','color',distinguishableColors(k,:),'LineWidth',1.0);
    plot_Google_FLP_Accuracy_Radius(GoogleFLPLocationDegree, GoogleFLPAccuracyMeter, distinguishableColors(k,:), 0.1);
end
plot_google_map('maptype', 'roadmap', 'APIKey', 'AIzaSyB_uD1rGjX6MJkoQgSDyjHkbdu-b-_5Bjg');
xlabel('Longitude [deg]','FontName','Times New Roman','FontSize',17);
ylabel('Latitude [deg]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure












