function [residuals] = EuclideanDistanceResidual_All(startLocation, sensorMeasurements, X)

% unpack sensor measurements
TangoPolarVIODistance = sensorMeasurements.TangoPolarVIODistance;
TangoPolarVIOAngle = sensorMeasurements.TangoPolarVIOAngle;
TangoGoogleFLPIndex = sensorMeasurements.TangoGoogleFLPIndex;
TangoGoogleFLPLocation = sensorMeasurements.TangoGoogleFLPLocation;
TangoGoogleFLPAccuracy = sensorMeasurements.TangoGoogleFLPAccuracy;
%TangoGoogleFLPAccuracy = TangoGoogleFLPAccuracy - 10;


% Tango VIO drift correction model
[scale, bias] = unpackTempFunction(X);
TangoVIOLocation = DriftCorrectedTempFunction(startLocation, scale, bias, TangoPolarVIODistance, TangoPolarVIOAngle);


% (1) residuals for Google FLP location
TangoEstimatedLocation = TangoVIOLocation(:,TangoGoogleFLPIndex);
TangoLocationNormError = vecnorm(TangoEstimatedLocation - TangoGoogleFLPLocation);
residualGoogleFLP = max((TangoLocationNormError - TangoGoogleFLPAccuracy), 0);


% (2) residuals for stationary (same) points
residualStationaryPoint(1) = norm(TangoVIOLocation(:,301) - TangoVIOLocation(:,302));

residualStationaryPoint(2) = norm(TangoVIOLocation(:,601) - TangoVIOLocation(:,602));
residualStationaryPoint(3) = norm(TangoVIOLocation(:,602) - TangoVIOLocation(:,1692));

residualStationaryPoint(4) = norm(TangoVIOLocation(:,1151) - TangoVIOLocation(:,1152));


% (3) residuals for scale/bias changes in Tango VIO drift correction model
scaleRegularization = (scale - 1);
biasRegularization = (bias - 0);


% (4) final residuals for nonlinear optimization
residuals = [5*residualGoogleFLP, 10*residualStationaryPoint, scaleRegularization, biasRegularization].';


end

