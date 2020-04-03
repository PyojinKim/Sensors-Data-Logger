function [residuals] = EuclideanDistanceResidual_RoNIN_GoogleFLP_test(sensorMeasurements, X)

% unpack sensor measurements
RoninPolarIODistance = sensorMeasurements.RoninPolarIODistance;
RoninPolarIOAngle = sensorMeasurements.RoninPolarIOAngle;
RoninGoogleFLPIndex = sensorMeasurements.RoninGoogleFLPIndex;
RoninGoogleFLPLocation = sensorMeasurements.RoninGoogleFLPLocation;
RoninGoogleFLPAccuracy = sensorMeasurements.RoninGoogleFLPAccuracy;

RoninStartLocation = sensorMeasurements.RoninStartLocation;
RoninEndLocation = sensorMeasurements.RoninEndLocation;
RoninAcceptableRadius = sensorMeasurements.RoninAcceptableRadius;


% Ronin IO drift correction model
[startLocation, rotation, scale, bias] = unpackDriftCorrectionRoninIOModelParameters(X);
RoninIOLocation = DriftCorrectedRoninIOAbsoluteAngleModel(startLocation, rotation, scale, bias, RoninPolarIODistance, RoninPolarIOAngle);


% (1) residuals for Google FLP location
RoninEstimatedLocation = RoninIOLocation(:,RoninGoogleFLPIndex);
RoninLocationNormError = vecnorm(RoninEstimatedLocation - RoninGoogleFLPLocation);
residualGoogleFLP = max((RoninLocationNormError - RoninGoogleFLPAccuracy), 0);


% (2) residuals for scale/bias changes in Ronin IO drift correction model
scaleRegularization = (scale - 1);
biasRegularization = (bias - 0);


% (3) residuals for landmarks
RoninLocationNormError = [norm(RoninIOLocation(:,1) - RoninStartLocation), norm(RoninIOLocation(:,end) - RoninEndLocation)];
residualLandmarks = max((RoninLocationNormError - [RoninAcceptableRadius, RoninAcceptableRadius]), 0);


% (4) final residuals for nonlinear optimization
%residuals = [residualGoogleFLP, scaleRegularization, biasDifference].';
residuals = [5*residualGoogleFLP, 5*residualLandmarks, scaleRegularization, biasRegularization].';
%residuals = [residualGoogleFLP].';


end

