function plot_Google_FLP_Accuracy_Radius(GoogleFLPLocationDegree, GoogleFLPAccuracyMeter, circleColor, circleAlpha)

% convert lat/lon coordinates (deg) to mercator coordinates (m)
scale = latToScale(GoogleFLPLocationDegree(1,1));
latitude = GoogleFLPLocationDegree(1,:);
longitude = GoogleFLPLocationDegree(2,:);
[X,Y] = latlonToMercator(latitude, longitude, scale);


% plot Google FLP accuracy (uncertainty) radius
numData = size(GoogleFLPLocationDegree,2);
for k = 1:numData
    [lon, lat] = convertAccuracyDegree(X(k), Y(k), GoogleFLPAccuracyMeter(k), scale);
    
    h_circle_line = plot(lon, lat,'color',circleColor,'LineWidth',1.0);
    
    h_circle_patch = patch(lon,lat,'b');
    h_circle_patch.FaceColor = circleColor;
    h_circle_patch.EdgeColor = circleColor;
    h_circle_patch.FaceAlpha = circleAlpha;
end


end


% % plot Google FLP uncertainty radius
% [lon, lat] = convertAccuracyDegree(syncFLPPoseMeter(1,k), syncFLPPoseMeter(2,k), syncFLPAccuracyMeter(k), scale);
% h_FLP_radius = plot(lon, lat, 'b','LineWidth',3);