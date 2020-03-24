function [scale, bias] = unpackTempFunction(X_Model_Parameters)

% scale and bias terms
numTangoVIO = size(X_Model_Parameters,2) / 2;
scale = X_Model_Parameters(1:numTangoVIO);
bias = X_Model_Parameters((numTangoVIO+1):(2*numTangoVIO));


end

