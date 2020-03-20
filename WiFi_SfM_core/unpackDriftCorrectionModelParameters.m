function [startLocation, rotation, scale, bias] = unpackDriftCorrectionModelParameters(X_Model_Parameters)

% start location and rotation
startLocation = X_Model_Parameters(1:2);
rotation = X_Model_Parameters(3);


% scale and bias terms
X_Model_Parameters = X_Model_Parameters(4:end);
numTangoVIO = size(X_Model_Parameters,2) / 2;
scale = X_Model_Parameters(1:numTangoVIO);
bias = X_Model_Parameters((numTangoVIO+1):(2*numTangoVIO));


end

