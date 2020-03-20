
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























