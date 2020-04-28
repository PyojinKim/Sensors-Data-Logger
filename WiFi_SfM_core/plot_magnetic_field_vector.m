function [h_magnet] = plot_magnetic_field_vector(position, magnet, color, width)

h_magnet = quiver3(position(1), position(2), position(3), magnet(1), magnet(2), magnet(3),...
    'Color',color,'LineWidth',width,'MaxHeadSize',1.0,'AlignVertexCenters','on');

end

