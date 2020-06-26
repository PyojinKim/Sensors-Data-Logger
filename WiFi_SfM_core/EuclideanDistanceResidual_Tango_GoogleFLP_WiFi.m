function [residuals] = EuclideanDistanceResidual_Tango_GoogleFLP_WiFi(sensorMeasurements, WiFiSimilarityIndex, X)

%
numRoninData = size(sensorMeasurements,2);
TangoVIOLocationSave = cell(1,numRoninData);
residualGoogleFLP = [];
for k = 1:numRoninData
    
    % unpack sensor measurements
    TangoPolarVIODistance = sensorMeasurements{k}.TangoPolarVIODistance;
    TangoPolarVIOAngle = sensorMeasurements{k}.TangoPolarVIOAngle;
    TangoGoogleFLPIndex = sensorMeasurements{k}.TangoGoogleFLPIndex;
    TangoGoogleFLPLocation = sensorMeasurements{k}.TangoGoogleFLPLocation;
    TangoGoogleFLPAccuracy = sensorMeasurements{k}.TangoGoogleFLPAccuracy;
    
    
    % Tango VIO drift correction model
    startLocation = X((3*k-2):(3*k-1)).';
    rotation = X(3*k);
    numTangoVIO = size(TangoPolarVIODistance,2);
    scale = ones(1,numTangoVIO);
    bias = zeros(1,numTangoVIO);
    TangoVIOLocation = DriftCorrectedTangoVIOAbsoluteAngleModel(startLocation, rotation, scale, bias, TangoPolarVIODistance, TangoPolarVIOAngle);
    TangoVIOLocationSave{k} = TangoVIOLocation;
    
    
    % residuals for Google FLP location
    TangoEstimatedLocation = TangoVIOLocation(:,TangoGoogleFLPIndex);
    TangoLocationNormError = vecnorm(TangoEstimatedLocation - TangoGoogleFLPLocation);
    eachResidualGoogleFLP = max((TangoLocationNormError - TangoGoogleFLPAccuracy), 0);
    residualGoogleFLP = [residualGoogleFLP, eachResidualGoogleFLP];
end


% WiFi similarity constraints
numWiFiConstraints = size(WiFiSimilarityIndex,1);
TangoLocationNormError = zeros(numWiFiConstraints, (numRoninData-1));
for k = 1:numWiFiConstraints
    for m = 1:(numRoninData-1)
        
        % RoNIN sequence index
        roninQueryIndex = 1;
        roninTestIndex = (m+1);
        
        % WiFi index
        queryIndex = WiFiSimilarityIndex(k,roninQueryIndex);
        testIndex = WiFiSimilarityIndex(k,roninTestIndex);
        TangoLocationNormError(k,m) = norm(TangoVIOLocationSave{roninQueryIndex}(:,queryIndex) - TangoVIOLocationSave{roninTestIndex}(:,testIndex));
    end
end
TangoLocationNormError = TangoLocationNormError(:).';
residualWiFi = max((TangoLocationNormError - 0.0), 0);


% (3) final residuals for nonlinear optimization
%residuals = [residualWiFi];
residuals = [residualGoogleFLP, residualWiFi];
residuals = lossFunction(residuals.^2, 'Cauchy');


end

