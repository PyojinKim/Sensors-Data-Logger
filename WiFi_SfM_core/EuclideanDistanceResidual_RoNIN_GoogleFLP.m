function [residuals] = EuclideanDistanceResidual_RoNIN_GoogleFLP(sensorMeasurements, X)

% unpack sensor measurements
RoninPolarIODistance = sensorMeasurements.RoninPolarIODistance;
RoninPolarIOAngle = sensorMeasurements.RoninPolarIOAngle;
RoninGoogleFLPIndex = sensorMeasurements.RoninGoogleFLPIndex;
RoninGoogleFLPLocation = sensorMeasurements.RoninGoogleFLPLocation;
RoninGoogleFLPAccuracy = sensorMeasurements.RoninGoogleFLPAccuracy;


% Ronin IO drift correction model
%[startLocation, rotation, scale, bias] = unpackDriftCorrectionModelParameters(X);
startLocation = X(1:2);
rotation = X(3);
numRoninIO = size(RoninPolarIODistance,2);
scale = ones(1,numRoninIO);
bias = zeros(1,numRoninIO);
RoninIOLocation = DriftCorrectedRoninIOAbsoluteAngleModel(startLocation, rotation, scale, bias, RoninPolarIODistance, RoninPolarIOAngle);


% (1) residuals for Google FLP location
RoninEstimatedLocation = RoninIOLocation(:,RoninGoogleFLPIndex);
RoninLocationNormError = vecnorm(RoninEstimatedLocation - RoninGoogleFLPLocation);
residualGoogleFLP = max((RoninLocationNormError - RoninGoogleFLPAccuracy), 0);


% (2) residuals for scale/bias changes in Ronin IO drift correction model
scaleRegularization = (scale - 1);
biasRegularization = (bias - 0);


% (3) final residuals for nonlinear optimization
%residuals = [residualGoogleFLP, scaleRegularization, biasDifference].';
%residuals = [residualGoogleFLP, scaleRegularization, biasRegularization].';
residuals = [residualGoogleFLP].';


end

