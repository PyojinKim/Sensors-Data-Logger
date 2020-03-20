function [TangoVIOLocation] = DriftCorrectedTangoVIOAbsoluteAngleModel(startLocation, rotation, scale, bias, TangoPolarDistance, TangoPolarAngle)

% compute drift-corrected Tango VIO location
numTangoVIO = size(TangoPolarDistance,2);
TangoVIOLocation = zeros(2,numTangoVIO);
TangoVIOLocation(:,1) = startLocation;
for k = 2:numTangoVIO
    
    % scale and bias for each segment
    s = scale(k);
    b = bias(k);
    
    % compute delta X and Y
    deltaX = s * TangoPolarDistance(k) * cos(TangoPolarAngle(k) + b);
    deltaY = s * TangoPolarDistance(k) * sin(TangoPolarAngle(k) + b);
    
    % accumulated Tango VIO location
    TangoVIOLocation(:,k) = TangoVIOLocation(:,k-1) + [deltaX; deltaY];
end


% whole Tango VIO trajectory rotation
R = angle2rotmtx([0;0;rotation]);
R = R(1:2,1:2);
TangoVIOLocation = R * TangoVIOLocation;


end

