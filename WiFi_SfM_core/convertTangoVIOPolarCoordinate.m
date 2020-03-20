function [TangoPolarVIO] = convertTangoVIOPolarCoordinate(TangoVIO)

% new TangoVIO in polar coordinate frame
numTangoVIO = size(TangoVIO,2);
TangoPolarVIO(1).location = TangoVIO(1).location;
TangoPolarVIO(1).distance = 0.0;
TangoPolarVIO(1).angle = 0.0;
for k = 2:numTangoVIO
    
    % compute distance & angle
    deltaLocation = (TangoVIO(k).location - TangoVIO(k-1).location);
    distance = norm(deltaLocation);
    angle = atan2(deltaLocation(2), deltaLocation(1));
    
    
    % save each Tango VIO distance & angle
    TangoPolarVIO(k).location = TangoVIO(k).location;
    TangoPolarVIO(k).distance = distance;
    TangoPolarVIO(k).angle = angle;
end


end

