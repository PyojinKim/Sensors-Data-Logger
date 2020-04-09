

testRoninIndex = [33 34 43 51 54];


landmark0 = [-0.9501; -0.4317];        %
landmark1 = [59.7968; 102.5964];      %


landmark2 = [-72.4734; 157.0987];      %  [-77.2317;167.1192];


landmark3 = [-258.8647; 251.0013];    %
landmark4 =  [-157.3795; 312.6015];    %  [-158.5248;311.1681];


landmark1 = [60.2155; 100.7677];      %
landmark6 = [175.8821; 146.4139];
radius = 2.0;


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


testRoninIndex = [18 31 42];


testRoninIndex = [1 8 9 16 26 27 39 48];


testRoninIndex = [33 34 43 51 54];


testRoninIndex = [10 15 21 28 38 47];


% optimized RoNIN IO visualization
for k = testRoninIndex
    
    % current RoNIN IO data
    RoninIO = datasetRoninIO{k};
    RoninIOLocation = [RoninIO.location];
    
    
    % plot RoNIN IO location
    distinguishableColors = distinguishable_colors(numDatasetList);
    figure(10); hold on; grid on; axis equal; axis tight;
    plot(RoninIOLocation(1,:),RoninIOLocation(2,:),'-','color',distinguishableColors(k,:),'LineWidth',1.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure
    
    
    
%     delete(h_text);
%     h_text = text(-100, 50, 0, sprintf('%02d', k),'Color','k','FontSize',11,'FontWeight','bold');
    
    
%     k
%     pause(2)
end

