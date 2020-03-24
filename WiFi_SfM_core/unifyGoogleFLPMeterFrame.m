function [datasetTangoVIO] = unifyGoogleFLPMeterFrame(datasetTangoVIO)

% unify / convert Google FLP to meter metric
numDatasetList = size(datasetTangoVIO,2);
isGoogleFLPInitialized = false;
for k = 1:numDatasetList
    
    % current Tango VIO data
    TangoVIO = datasetTangoVIO{k};
    numTangoVIO = size(TangoVIO,2);
    for m = 1:numTangoVIO
        
        % check Google FLP exist or not
        if (~isempty(TangoVIO(m).FLPLocationDegree))
            
            % define reference Google FLP scale, origin in meter
            if (~isGoogleFLPInitialized)
                isGoogleFLPInitialized = true;
                
                scaleRef = latToScale(TangoVIO(m).FLPLocationDegree(1));
                latitude = TangoVIO(m).FLPLocationDegree(1);
                longitude = TangoVIO(m).FLPLocationDegree(2);
                [XRef,YRef] = latlonToMercator(latitude, longitude, scaleRef);
            end
            
            
            % convert lat/lon coordinates (deg) to mercator coordinates (m)
            latitude = TangoVIO(m).FLPLocationDegree(1);
            longitude = TangoVIO(m).FLPLocationDegree(2);
            [X,Y] = latlonToMercator(latitude, longitude, scaleRef);
            
            X = X - XRef;
            Y = Y - YRef;
            TangoVIO(m).FLPLocationMeter = [X;Y];
        end
    end
    
    
    % save Tango VIO
    datasetTangoVIO{k} = TangoVIO;
end


end

