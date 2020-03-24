function [datasetGoogleFLPResult] = unifyGoogleFLPMeterFrameForWiFiSfM(datasetGoogleFLPResult)

% unify / convert Google FLP to meter metric
numDatasetList = size(datasetGoogleFLPResult,2);
isGoogleFLPInitialized = false;
for k = 1:numDatasetList
    
    % current Google FLP data
    GoogleFLPResult = datasetGoogleFLPResult{k};
    numGoogleFLP = size(GoogleFLPResult,2);
    for m = 1:numGoogleFLP
        
        % check Google FLP exist or not
        if (~isempty(GoogleFLPResult(m).locationDegree))
            
            % define reference Google FLP scale, origin in meter
            if (~isGoogleFLPInitialized)
                isGoogleFLPInitialized = true;
                
                scaleRef = latToScale(GoogleFLPResult(m).locationDegree(1));
                latitude = GoogleFLPResult(m).locationDegree(1);
                longitude = GoogleFLPResult(m).locationDegree(2);
                [XRef,YRef] = latlonToMercator(latitude, longitude, scaleRef);
            end
            
            
            % convert lat/lon coordinates (deg) to mercator coordinates (m)
            latitude = GoogleFLPResult(m).locationDegree(1);
            longitude = GoogleFLPResult(m).locationDegree(2);
            [X,Y] = latlonToMercator(latitude, longitude, scaleRef);
            
            X = X - XRef;
            Y = Y - YRef;
            GoogleFLPResult(m).locationMeter = [X;Y];
        end
    end
    
    
    % save Tango VIO
    datasetGoogleFLPResult{k} = GoogleFLPResult;
end


end

