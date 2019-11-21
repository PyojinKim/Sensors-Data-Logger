function [accuracy_radius_lon, accuracy_radius_lat] = convertAccuracyDegree(x_center_meter, y_center_meter, accuracy_meter, scale)

% convert
theta = [0:pi/50:2*pi];
accuracy_radius_x_meter = x_center_meter + accuracy_meter * cos(theta);
accuracy_radius_y_meter = y_center_meter + accuracy_meter * sin(theta);
[accuracy_radius_lon, accuracy_radius_lat] = mercatorToLatLon(accuracy_radius_x_meter, accuracy_radius_y_meter, scale);

end





