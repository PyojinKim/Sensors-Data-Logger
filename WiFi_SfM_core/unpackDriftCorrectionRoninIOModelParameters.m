function [startLocation, rotation, scale, bias] = unpackDriftCorrectionRoninIOModelParameters(X_Model_Parameters)

% start location and rotation
startLocation = X_Model_Parameters(1:2);
rotation = X_Model_Parameters(3);


% scale and bias terms
X_Model_Parameters = X_Model_Parameters(4:end);
numRoninIO = size(X_Model_Parameters,2) / 2;
scale = X_Model_Parameters(1:numRoninIO);
bias = X_Model_Parameters((numRoninIO+1):(2*numRoninIO));


end

