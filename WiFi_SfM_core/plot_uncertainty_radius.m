function plot_uncertainty_radius(center, radius, circleColor, circleWidth)

% x,y position of circle
theta = [0:pi/50:2*pi];
uncertaintyRadiusX = center(1) + radius * cos(theta);
uncertaintyRadiusY = center(2) + radius * sin(theta);
plot(uncertaintyRadiusX, uncertaintyRadiusY,'color',circleColor,'LineWidth',circleWidth);

end

