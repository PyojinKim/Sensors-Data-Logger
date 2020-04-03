


landmark1 = [-78.9318;166.8808];     %
landmark2 = [-156.3401;311.3362];    %
radius = 5.0;




% current RoNIN IO data
RoninIOLocation = [RoninIO.location];
RoninFLPLocationMeter = [RoninIO.FLPLocationMeter];



% plot RoNIN IO location
distinguishableColors = distinguishable_colors(numDatasetList);
figure; hold on; grid on; axis equal; axis tight;
plot(RoninIOLocation(1,:),RoninIOLocation(2,:),'-','color',distinguishableColors(1,:),'LineWidth',1.5); grid on; axis equal;
plot(RoninFLPLocationMeter(1,:),RoninFLPLocationMeter(2,:),'*-','color',distinguishableColors(2,:),'LineWidth',1.5);
xlabel('X [m]','FontName','Times New Roman','FontSize',15);
ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure



figure;
subplot(2,1,1);
plot(scale); grid on; axis tight;
subplot(2,1,2);
plot(bias); grid on; axis tight;




%%


% optimized RoNIN IO visualization
for k = 49:numDatasetList
    
    % current RoNIN IO data
    RoninIO = datasetRoninIO{k};
    RoninIOLocation = [RoninIO.location];
    
    
    % plot RoNIN IO location
    distinguishableColors = distinguishable_colors(numDatasetList);
    figure(10); hold on; grid on; axis equal; axis tight;
    plot(RoninIOLocation(1,:),RoninIOLocation(2,:),'-','color',distinguishableColors(k,:),'LineWidth',1.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    k
    pause(2);
end




% Google FLP visualization
for k = 49:numDatasetList
    
    % current RoNIN IO data
    RoninIO = datasetRoninIO{k};
    RoninIOLocation = [RoninIO.FLPLocationMeter];
    
    
    % plot RoNIN IO location
    distinguishableColors = distinguishable_colors(numDatasetList);
    figure(10); hold on; grid on; axis equal; axis tight;
    plot(RoninIOLocation(1,:),RoninIOLocation(2,:),'*-','color',distinguishableColors(k,:),'LineWidth',1.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure
    k
    pause(2);
end

