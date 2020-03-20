function [residuals] = EuclideanDistanceResidual_GoogleFLP(sensorMeasurements, X)

% unpack sensor measurements
TangoPolarVIODistance = sensorMeasurements.TangoPolarVIODistance;
TangoPolarVIOAngle = sensorMeasurements.TangoPolarVIOAngle;
TangoGoogleFLPIndex = sensorMeasurements.TangoGoogleFLPIndex;
TangoGoogleFLPLocation = sensorMeasurements.TangoGoogleFLPLocation;
TangoGoogleFLPAccuracy = sensorMeasurements.TangoGoogleFLPAccuracy;
%TangoGoogleFLPAccuracy = TangoGoogleFLPAccuracy - 5;


% Tango VIO drift correction model
[startLocation, rotation, scale, bias] = unpackDriftCorrectionModelParameters(X);
TangoVIOLocation = DriftCorrectedTangoVIOAbsoluteAngleModel(startLocation, rotation, scale, bias, TangoPolarVIODistance, TangoPolarVIOAngle);


% (1) residuals for Google FLP location
TangoEstimatedLocation = TangoVIOLocation(:,TangoGoogleFLPIndex);
TangoLocationError = (TangoEstimatedLocation - TangoGoogleFLPLocation);
TangoLocationNormError = vecnorm(TangoLocationError);
residualGoogleFLP = max((TangoLocationNormError - TangoGoogleFLPAccuracy), 0);
%residualGoogleFLP = vecnorm(TangoLocationError);


% (2) residuals for scale/bias changes in RoNIN drift correction model
scaleRegularization = (scale - 1);
biasRegularization = (bias - 0);
biasDifference = diff(bias);


% (3) final residuals for nonlinear optimization
%residuals = [residualGoogleFLP, scaleRegularization, biasDifference].';
residuals = [residualGoogleFLP, scaleRegularization, biasRegularization].';
%residuals = [residualGoogleFLP].';


end

