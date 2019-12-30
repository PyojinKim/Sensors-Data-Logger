function [positionMeter, scale] = degreeToMeter(positionDegree)

scale = latToScale(positionDegree(1));
[X,Y] = latlonToMercator(positionDegree(1), positionDegree(2), scale);
positionMeter = [X;Y];

end

