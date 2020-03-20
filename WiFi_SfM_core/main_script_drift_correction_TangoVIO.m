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


% parse pose.txt / FLP.txt file
k = 16;
datasetDirectory = [datasetPath '\' datasetList(k).name];
TangoVIOInterval = 50;
accuracyThreshold = 25;
TangoVIO = extractTangoVIOCentricData(datasetDirectory, TangoVIOInterval, accuracyThreshold);


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


%% measurements (constants)

% Tango VIO constraints
TangoPolarVIO = convertTangoVIOPolarCoordinate(TangoVIO);
numTangoVIO = size(TangoPolarVIO,2);


% Google FLP constraints
TangoGoogleFLPIndex = [];
for k = 1:numTangoVIO
    if (~isempty(TangoVIO(k).FLPLocationMeter))
        TangoGoogleFLPIndex = [TangoGoogleFLPIndex, k];
    end
end
TangoGoogleFLPLocation = [TangoVIO.FLPLocationMeter];


% save sensor measurements (Tango VIO, Google FLP)
sensorMeasurements.TangoPolarVIODistance = [TangoPolarVIO.distance];
sensorMeasurements.TangoPolarVIOAngle = [TangoPolarVIO.angle];
sensorMeasurements.TangoGoogleFLPIndex = TangoGoogleFLPIndex;
sensorMeasurements.TangoGoogleFLPLocation = TangoGoogleFLPLocation;
sensorMeasurements.TangoGoogleFLPAccuracy = [TangoVIO.FLPAccuracyMeter];


%% model parameters (variables)

% initialize Tango VIO drift correction model parameters
modelParameters.startLocation = TangoGoogleFLPLocation(:,1).';
modelParameters.rotation = 0;
modelParameters.scale = ones(1,numTangoVIO);
modelParameters.bias = zeros(1,numTangoVIO);
X_initial = [modelParameters.startLocation, modelParameters.rotation, modelParameters.scale, modelParameters.bias];


%%

modelParameters
sensorMeasurements



% run nonlinear optimization using lsqnonlin in Matlab (Levenberg-Marquardt)
options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt','Display','iter-detailed','MaxIterations',400);
[vec,resnorm,residuals,exitflag] = lsqnonlin(@(x) EuclideanDistanceResidual_GoogleFLP(sensorMeasurements, x),X_initial,[],[],options);


% unpack sensor measurements
TangoPolarVIODistance = sensorMeasurements.TangoPolarVIODistance;
TangoPolarVIOAngle = sensorMeasurements.TangoPolarVIOAngle;


% optimal scale and bias model parameters for RoNIN drift correction model
X_optimized = vec;
[startLocation, rotation, scale, bias] = unpackDriftCorrectionModelParameters(X_optimized);
TangoVIOLocation = DriftCorrectedTangoVIOAbsoluteAngleModel(startLocation, rotation, scale, bias, TangoPolarVIODistance, TangoPolarVIOAngle);


figure;
plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'k-','LineWidth',1.5); hold on; grid on; axis equal; axis tight;
plot(TangoGoogleFLPLocation(1,:),TangoGoogleFLPLocation(2,:),'m*-','LineWidth',1.5);
xlabel('X [m]','FontName','Times New Roman','FontSize',15);
ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
title('Tango VIO History');

















