

% between (0) and (1)
testRoninIndex = [1 8 9 16 26 27 39 40 48];


% between (1) and (2)
testRoninIndex = [2 7 17 22 25 41];


% between (2) and (3)
testRoninIndex = [5 6 23 24 32 35 44 50 55];


% between (3) and (4)
testRoninIndex = [33 34 43 51 54];


% between (4) and (2)
testRoninIndex = [3 4 18 31 42];


% optimized RoNIN IO visualization
for k = testRoninIndex
    
    % current RoNIN IO data
    RoninIO = datasetRoninIO{k};
    RoninIOLocation = [RoninIO.location];
    
    
    % plot RoNIN IO location
    distinguishableColors = distinguishable_colors(numDatasetList);
    figure(15); hold on; grid on; axis equal; axis tight;
    plot(RoninIOLocation(1,:),RoninIOLocation(2,:),'-','color',distinguishableColors(k,:),'LineWidth',1.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure
end


%%


datasetRoninIndex = 6;
RoninIO = datasetRoninIO{datasetRoninIndex};


% RoNIN IO constraints (relative movement)
RoninPolarIO = convertRoninPolarCoordinate(RoninIO);
numRoninIO = size(RoninPolarIO,2);


% Google FLP constraints (global location)
RoninGoogleFLPIndex = [];
for k = 1:numRoninIO
    if (~isempty(RoninIO(k).FLPLocationMeter))
        RoninGoogleFLPIndex = [RoninGoogleFLPIndex, k];
    end
end
RoninGoogleFLPLocation = [RoninIO.FLPLocationMeter];


% sensor measurements from RoNIN IO, Google FLP
sensorMeasurements.RoninPolarIODistance = [RoninPolarIO.distance];
sensorMeasurements.RoninPolarIOAngle = [RoninPolarIO.angle];
sensorMeasurements.RoninGoogleFLPIndex = RoninGoogleFLPIndex;
sensorMeasurements.RoninGoogleFLPLocation = RoninGoogleFLPLocation;
sensorMeasurements.RoninGoogleFLPAccuracy = [RoninIO.FLPAccuracyMeter];


% optimal model parameters for RoNIN IO drift correction model
RoninPolarIODistance = sensorMeasurements.RoninPolarIODistance;
RoninPolarIOAngle = sensorMeasurements.RoninPolarIOAngle;


startLocation = RoninGoogleFLPLocation(:,1).';
rotation = -pi;

scale = ones(1,numRoninIO);
bias = zeros(1,numRoninIO);
RoninIOLocation = DriftCorrectedRoninIOAbsoluteAngleModel(startLocation, rotation, scale, bias, RoninPolarIODistance, RoninPolarIOAngle);





% current RoNIN IO data
RoninIOLocation = [RoninIO.FLPLocationMeter];



% plot RoNIN IO location
distinguishableColors = distinguishable_colors(numDatasetList);
figure(10); hold on; grid on; axis equal; axis tight;
plot(RoninIOLocation(1,:),RoninIOLocation(2,:),'*-','color','m','LineWidth',1.5); grid on; axis equal;
xlabel('X [m]','FontName','Times New Roman','FontSize',15);
ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure




% plot RoNIN IO location
distinguishableColors = distinguishable_colors(numDatasetList);
figure(10); hold on; grid on; axis equal; axis tight;
plot(RoninIOLocation(1,:),RoninIOLocation(2,:),'-','color','m','LineWidth',1.0); grid on; axis equal;
xlabel('X [m]','FontName','Times New Roman','FontSize',15);
ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure























