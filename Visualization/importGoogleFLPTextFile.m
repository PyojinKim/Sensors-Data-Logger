function [poseDegree, poseTime, poseMeter, accuracyMeter] = importGoogleFLPTextFile(FLPTextFile)

% common setting to read text files
delimiter = ' ';
headerlinesIn = 1;
nanoSecondToSecond = 1000000000;


% import Google FLP text
textFLPData = importdata(FLPTextFile, delimiter, headerlinesIn);
poseTime = textFLPData.data(:,1).';
poseTime = poseTime ./ nanoSecondToSecond;
poseDegree = textFLPData.data(:,[2 3]).';
accuracyMeter = textFLPData.data(:,4).';


% convert lat/lon coordinates (deg) to mercator coordinates (m)
scale = latToScale(poseDegree(1,1));
latitude = poseDegree(1,:);
longitude = poseDegree(2,:);
[X,Y] = latlonToMercator(latitude, longitude, scale);
poseMeter = [X;Y];


end

