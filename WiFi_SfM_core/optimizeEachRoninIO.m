function [RoninIO] = optimizeEachRoninIO(RoninIO)
%% (1) measurements (constants)

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


% Google FLP offset for 2D rigid body rotation
offset = RoninGoogleFLPLocation(:,1);
RoninGoogleFLPLocation = RoninGoogleFLPLocation - offset;


% check Google FLP data index
if (isempty(RoninGoogleFLPIndex))
    RoninIO = [];
    return;
end


% sensor measurements from RoNIN IO, Google FLP
sensorMeasurements.RoninPolarIODistance = [RoninPolarIO.distance];
sensorMeasurements.RoninPolarIOAngle = [RoninPolarIO.angle];
sensorMeasurements.RoninGoogleFLPIndex = RoninGoogleFLPIndex;
sensorMeasurements.RoninGoogleFLPLocation = RoninGoogleFLPLocation;
sensorMeasurements.RoninGoogleFLPAccuracy = [RoninIO.FLPAccuracyMeter];


%% (2) model parameters (variables) for RoNIN IO drift correction model

% initialize RoNIN IO drift correction model parameters
modelParameters.startLocation = RoninGoogleFLPLocation(:,1).';
modelParameters.rotation = 0;
X_initial = [modelParameters.startLocation, modelParameters.rotation];


%% (3) nonlinear optimization

% run nonlinear optimization using lsqnonlin in Matlab (Levenberg-Marquardt)
options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt','Display','iter-detailed','MaxIterations',400);
[vec,resnorm,residuals,exitflag] = lsqnonlin(@(x) EuclideanDistanceResidual_RoNIN_GoogleFLP(sensorMeasurements, x),X_initial,[],[],options);


% optimal model parameters for RoNIN IO drift correction model
RoninPolarIODistance = sensorMeasurements.RoninPolarIODistance;
RoninPolarIOAngle = sensorMeasurements.RoninPolarIOAngle;
X_optimized = vec;
startLocation = X_optimized(1:2).';
rotation = X_optimized(3);
scale = ones(1,numRoninIO);
bias = zeros(1,numRoninIO);
RoninIOLocation = DriftCorrectedRoninIOAbsoluteAngleModel(startLocation, rotation, scale, bias, RoninPolarIODistance, RoninPolarIOAngle);


% Google FLP offset for 2D rigid body rotation
RoninIOLocation = RoninIOLocation + offset;


% save drift-corrected RoNIN IO location
for k = 1:numRoninIO
    RoninIO(k).location = RoninIOLocation(:,k);
end


end

