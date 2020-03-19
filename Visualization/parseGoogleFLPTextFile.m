function [GoogleFLPResult] = parseGoogleFLPTextFile(GoogleFLPTextFile)

% common setting to read text files
delimiter = ' ';
headerlinesIn = 1;
nanoSecondToSecond = 1000000000;


% open Google FLP text file
textFLPData = importdata(GoogleFLPTextFile, delimiter, headerlinesIn);
GoogleFLPTime = textFLPData.data(:,1).';
GoogleFLPTime = GoogleFLPTime ./ nanoSecondToSecond;
GoogleFLPLocationDegree = textFLPData.data(:,[2 3]).';
GoogleFLPAccuracyMeter = textFLPData.data(:,4).';
numLocation = size(GoogleFLPLocationDegree,2);


% convert lat/lon coordinates (deg) to mercator coordinates (m)
scale = latToScale(GoogleFLPLocationDegree(1,1));
latitude = GoogleFLPLocationDegree(1,:);
longitude = GoogleFLPLocationDegree(2,:);
[X,Y] = latlonToMercator(latitude, longitude, scale);
X = X - X(1);
Y = Y - Y(1);
GoogleFLPLocationMeter = [X;Y];


% construct Google FLP results
GoogleFLPResult = struct('timestamp', cell(1,numLocation), 'locationDegree', cell(1,numLocation), 'locationMeter', cell(1,numLocation), 'accuracyMeter', cell(1,numLocation));
for k = 1:numLocation
    
    % save each Google FLP information
    GoogleFLPResult(k).timestamp = GoogleFLPTime(k);
    GoogleFLPResult(k).locationDegree = GoogleFLPLocationDegree(:,k);
    GoogleFLPResult(k).locationMeter = GoogleFLPLocationMeter(:,k);
    GoogleFLPResult(k).accuracyMeter = GoogleFLPAccuracyMeter(k);
end


end



