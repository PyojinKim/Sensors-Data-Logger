function [datasetRoninIO] = unifyRoninIOGoogleFLPMeterFrame(datasetRoninIO)

% unify / convert Google FLP to meter metric
numDatasetList = size(datasetRoninIO,2);
isGoogleFLPInitialized = false;
for k = 1:numDatasetList
    
    % current RoNIN IO data
    RoninIO = datasetRoninIO{k};
    numRoninIO = size(RoninIO,2);
    for m = 1:numRoninIO
        
        % check Google FLP exist or not
        if (~isempty(RoninIO(m).FLPLocationDegree))
            
            % define reference Google FLP scale, origin in meter
            if (~isGoogleFLPInitialized)
                isGoogleFLPInitialized = true;
                
                scaleRef = latToScale(RoninIO(m).FLPLocationDegree(1));
                latitude = RoninIO(m).FLPLocationDegree(1);
                longitude = RoninIO(m).FLPLocationDegree(2);
                [XRef,YRef] = latlonToMercator(latitude, longitude, scaleRef);
            end
            
            
            % convert lat/lon coordinates (deg) to mercator coordinates (m)
            latitude = RoninIO(m).FLPLocationDegree(1);
            longitude = RoninIO(m).FLPLocationDegree(2);
            [X,Y] = latlonToMercator(latitude, longitude, scaleRef);
            
            X = X - XRef;
            Y = Y - YRef;
            RoninIO(m).FLPLocationMeter = [X;Y];
        end
    end
    
    
    % save RoNIN IO
    datasetRoninIO{k} = RoninIO;
end


end


