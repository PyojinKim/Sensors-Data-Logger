function [GoogleFLPResult] = extractGoogleFLPCentricData(datasetDirectory, R, t, accuracyThreshold)

% parse FLP.txt file
GoogleFLPResult = parseGoogleFLPTextFile([datasetDirectory '/FLP.txt']);


% parse pose.txt file / transform to global inertial frame
TangoPoseResult = parseTangoPoseTextFile([datasetDirectory '/pose.txt']);
numPose = size(TangoPoseResult,2);
for m = 1:numPose
    transformedTangoPose = (R * TangoPoseResult(m).stateEsti_Tango(1:2) + t);
    TangoPoseResult(m).stateEsti_Tango = transformedTangoPose;
end


% label Google FLP with Tango VIO location
numGoogleFLP = size(GoogleFLPResult,2);
for m = 1:numGoogleFLP
    
    % current Google FLP data
    timestamp = GoogleFLPResult(m).timestamp;
    accuracyMeter = GoogleFLPResult(m).accuracyMeter;
    
    
    % find the closest Tango pose timestamp and true location
    [timeDifference, indexTango] = min(abs(timestamp - [TangoPoseResult.timestamp]));
    if ((timeDifference < 0.5) && (accuracyMeter < accuracyThreshold))
        GoogleFLPResult(m).trueLocation = TangoPoseResult(indexTango).stateEsti_Tango;
    end
end


% refine unlabeled Google FLP result
for m = numGoogleFLP:-1:1
    if (isempty(GoogleFLPResult(m).trueLocation))
        GoogleFLPResult(m) = [];
    end
end


end
