


%%


%
numRoninData = size(sensorMeasurements,2);
TangoVIOLocationSave = cell(1,numRoninData);
for k = 1:numRoninData
    
    % unpack sensor measurements
    TangoPolarVIODistance = sensorMeasurements{k}.TangoPolarVIODistance;
    TangoPolarVIOAngle = sensorMeasurements{k}.TangoPolarVIOAngle;
    
    
    % Tango VIO drift correction model
    startLocation = X_optimized((3*k-2):(3*k-1)).';
    rotation = X_optimized(3*k);
    numTangoVIO = size(TangoPolarVIODistance,2);
    scale = ones(1,numTangoVIO);
    bias = zeros(1,numTangoVIO);
    TangoVIOLocation = DriftCorrectedTangoVIOAbsoluteAngleModel(startLocation, rotation, scale, bias, TangoPolarVIODistance, TangoPolarVIOAngle);
    
    for m = 1:size(TangoVIOLocation,2)
        partialTangoVIO{k}(m).location = TangoVIOLocation(:,m);
    end
    
    k
end


%%


%
numRoninData = size(sensorMeasurements,2);
TangoVIOLocationSave = cell(1,numRoninData);
for k = 1:numRoninData
    
    % unpack sensor measurements
    TangoPolarVIODistance = sensorMeasurements{k}.TangoPolarVIODistance;
    TangoPolarVIOAngle = sensorMeasurements{k}.TangoPolarVIOAngle;
    
    
    % Tango VIO drift correction model
    startLocation = X_optimized((3*k-2):(3*k-1)).';
    rotation = X_optimized(3*k);
    numTangoVIO = size(TangoPolarVIODistance,2);
    scale = ones(1,numTangoVIO);
    bias = zeros(1,numTangoVIO);
    RoninIOLocation = DriftCorrectedTangoVIOAbsoluteAngleModel(startLocation, rotation, scale, bias, TangoPolarVIODistance, TangoPolarVIOAngle);
    
    for m = 1:size(RoninIOLocation,2)
        partialRoninIO{k}(m).location = RoninIOLocation(:,m);
    end
    
    k
end


%% make .avi file from png files

movie = VideoWriter('myAVI.avi');
movie.FrameRate = 1; % set fps
open(movie);

for queryIdx = 1:57
    
    % read PNG image file
    filename = sprintf('figures/%06d.png', queryIdx);
    im = imread(filename);
    
    % write video
    writeVideo(movie, im);
    
    queryIdx
end

close(movie);



