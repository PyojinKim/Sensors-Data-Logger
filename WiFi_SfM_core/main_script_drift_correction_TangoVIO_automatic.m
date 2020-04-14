clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;

addpath('devkit_KITTI_GPS');


%% 1) load Tango VIO data

% choose dataset path
datasetPath = 'G:\Smartphone_Dataset\4_WiFi_SfM\pyojin_Asus_Tango_SFU_Multiple_Buildings_withVIO';
datasetList = dir(datasetPath);
datasetList(1:2) = [];


% load Tango VIO data
numDatasetList = 55;
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


% label start and final FLP locations
for k = 1:numDatasetList
    
    % read manual alignment result
    expCase = k;
    manual_alignment_Asus_Tango_SFU_Multiple_Buildings_Landmarks;
    
    
    % update Tango VIO data
    TangoVIO = datasetTangoVIO{k};
    TangoVIO(1).FLPLocationMeter = startFLPLocationMeter;
    TangoVIO(1).FLPAccuracyMeter = FLPAccuracyMeter;
    TangoVIO(end).FLPLocationMeter = finalFLPLocationMeter;
    TangoVIO(end).FLPAccuracyMeter = FLPAccuracyMeter;
    
    
    % save Tango VIO
    datasetTangoVIO{k} = TangoVIO;
end


%% 2) optimize each Tango VIO against Google FLP

% initial 2D rigid body transformation w.r.t. Google FLP
for k = 1:numDatasetList
    
    % current Tango VIO data
    TangoVIO = datasetTangoVIO{k};
    
    
    % nonlinear optimization with Tango VIO drift correction model
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


%% temporary codes for testing idea

datasetTangoIndex = 2;
TangoVIO = datasetTangoVIO{datasetTangoIndex};


%% (1) measurements (constants)

% Tango VIO constraints (relative movement)
TangoPolarVIO = convertTangoVIOPolarCoordinate(TangoVIO);
numTangoVIO = size(TangoPolarVIO,2);


% Google FLP constraints (global location)
TangoGoogleFLPIndex = [];
for k = 1:numTangoVIO
    if (~isempty(TangoVIO(k).FLPLocationMeter))
        TangoGoogleFLPIndex = [TangoGoogleFLPIndex, k];
    end
end
TangoGoogleFLPLocation = [TangoVIO.FLPLocationMeter];


% sensor measurements from Tango VIO, Google FLP
sensorMeasurements.TangoPolarVIODistance = [TangoPolarVIO.distance];
sensorMeasurements.TangoPolarVIOAngle = [TangoPolarVIO.angle];
sensorMeasurements.TangoGoogleFLPIndex = TangoGoogleFLPIndex;
sensorMeasurements.TangoGoogleFLPLocation = TangoGoogleFLPLocation;
sensorMeasurements.TangoGoogleFLPAccuracy = [TangoVIO.FLPAccuracyMeter];


%% (2) model parameters (variables) for Tango VIO drift correction model

% initialize Tango VIO drift correction model parameters
modelParameters.startLocation = TangoGoogleFLPLocation(:,1).';
modelParameters.rotation = 0;
modelParameters.scale = ones(1,numTangoVIO);
modelParameters.bias = zeros(1,numTangoVIO);
X_initial = [modelParameters.startLocation, modelParameters.rotation, modelParameters.scale, modelParameters.bias];


%% (3) nonlinear optimization

% run nonlinear optimization using lsqnonlin in Matlab (Levenberg-Marquardt)
options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt','Display','iter-detailed','MaxIterations',400);
[vec,resnorm,residuals,exitflag] = lsqnonlin(@(x) EuclideanDistanceResidual_Tango_GoogleFLP_test(sensorMeasurements, x),X_initial,[],[],options);


% optimal model parameters for Tango VIO drift correction model
TangoPolarVIODistance = sensorMeasurements.TangoPolarVIODistance;
TangoPolarVIOAngle = sensorMeasurements.TangoPolarVIOAngle;
X_optimized = vec;
[startLocation, rotation, scale, bias] = unpackDriftCorrectionModelParameters(X_optimized);
TangoVIOLocation = DriftCorrectedTangoVIOAbsoluteAngleModel(startLocation, rotation, scale, bias, TangoPolarVIODistance, TangoPolarVIOAngle);


% save drift-corrected Tango VIO location
for k = 1:numTangoVIO
    TangoVIO(k).location = TangoVIOLocation(:,k);
end
datasetTangoVIO{datasetTangoIndex} = TangoVIO;







