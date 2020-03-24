%% 3) optimize entire Tango VIO against Google FLP and landmark points


entireTangoVIO = [];
for k = 1:4
    
    % current Tango VIO data
    TangoVIO = datasetTangoVIO{k};
    entireTangoVIO = [entireTangoVIO, TangoVIO];
end


% Tango VIO constraints (relative movement)
entireTangoPolarVIO = convertTangoVIOPolarCoordinate(entireTangoVIO);
numEntireTangoVIO = size(entireTangoPolarVIO,2);


% Google FLP constraints (global location)
TangoGoogleFLPIndex = [];
for k = 1:numEntireTangoVIO
    if (~isempty(entireTangoVIO(k).FLPLocationMeter))
        TangoGoogleFLPIndex = [TangoGoogleFLPIndex, k];
    end
end
TangoGoogleFLPLocation = [entireTangoVIO.FLPLocationMeter];


% sensor measurements from Tango VIO, Google FLP
sensorMeasurements.TangoPolarVIODistance = [entireTangoPolarVIO.distance];
sensorMeasurements.TangoPolarVIOAngle = [entireTangoPolarVIO.angle];
sensorMeasurements.TangoGoogleFLPIndex = TangoGoogleFLPIndex;
sensorMeasurements.TangoGoogleFLPLocation = TangoGoogleFLPLocation;
sensorMeasurements.TangoGoogleFLPAccuracy = [entireTangoVIO.FLPAccuracyMeter];


% initialize Tango VIO drift correction model parameters
modelParameters.scale = ones(1,numEntireTangoVIO);
modelParameters.bias = zeros(1,numEntireTangoVIO);
X_initial = [modelParameters.scale, modelParameters.bias];


% run nonlinear optimization using lsqnonlin in Matlab (Levenberg-Marquardt)
options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt','Display','iter-detailed','MaxIterations',400);
[vec,resnorm,residuals,exitflag] = lsqnonlin(@(x) EuclideanDistanceResidual_All(entireTangoVIO(1).location, sensorMeasurements, x),X_initial,[],[],options);


% optimal model parameters for Tango VIO drift correction model
TangoPolarVIODistance = sensorMeasurements.TangoPolarVIODistance;
TangoPolarVIOAngle = sensorMeasurements.TangoPolarVIOAngle;
X_optimized = vec;
[scale, bias] = unpackTempFunction(X_optimized);
TangoVIOLocation = DriftCorrectedTempFunction(entireTangoVIO(1).location, scale, bias, TangoPolarVIODistance, TangoPolarVIOAngle);


figure;
plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'k-','LineWidth',1.5); grid on; axis equal; axis tight;
xlabel('X [m]','FontName','Times New Roman','FontSize',15);
ylabel('Y [m]','FontName','Times New Roman','FontSize',15);


figure;
subplot(2,1,1)
plot(scale);
subplot(2,1,2)
plot(bias);















