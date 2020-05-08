


%% WiFi localization heat map video clip

% create figure frame for making video
h_WiFi = figure(10);
set(h_WiFi,'Color',[1 1 1]);
set(h_WiFi,'Units','pixels','Position',[100 100 1800 850]);
ha1 = axes('Position',[0.02,0.05 , 0.60,0.90]); % [x_start, y_start, x_width, y_width]
ha2 = axes('Position',[0.68,0.25 , 0.30,0.50]); % [x_start, y_start, x_width, y_width]
for queryIdx = 1:numTestWiFiScan
    %% prerequisite to visualize
    
    % re-arrange WiFi scan location
    maxRewardIndex = testWiFiScanResult(queryIdx).maxRewardIndex;
    rewardResult = testWiFiScanResult(queryIdx).rewardResult;
    
    databaseWiFiScanLocation = [wifiFingerprintDatabase(:).trueLocation];
    trueLocation = testWiFiScanResult(queryIdx).trueLocation;
    maxRewardWiFiScanLocation = [wifiFingerprintDatabase(maxRewardIndex).trueLocation];
    
    
    %% update WiFi scan location with distance (reward function) heat map
    
    axes(ha1); cla;
    
    testRoninIndex = [1 8 9 16 26 27 39 40 48];
    for k = testRoninIndex
        
        % current Tango VIO data
        TangoVIO = datasetTangoVIO{k};
        TangoVIOLocation = [TangoVIO.location];
        
        % plot Tango VIO location
        distinguishableColors = distinguishable_colors(numDatasetList);
        plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'-','color',distinguishableColors(k,:),'LineWidth',0.5); hold on; grid on; axis equal;
        xlabel('X [m]','FontName','Times New Roman','FontSize',15);
        ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    end
    
    scatter(databaseWiFiScanLocation(1,:),databaseWiFiScanLocation(2,:),500,rewardResult,'.'); hold on; grid on;
    scatter(trueLocation(1),trueLocation(2),500,'kd','LineWidth',5);
    scatter(trueLocation(1),trueLocation(2),500,'k.');
    scatter(maxRewardWiFiScanLocation(1,:),maxRewardWiFiScanLocation(2,:),300,'md','LineWidth',3);
    colormap(jet); colorbar;
    xlabel('X [m]'); ylabel('Y [m]'); axis equal; axis tight;
    
    
    %% update reward metric result
    
    axes(ha2); cla;
    plot(rewardResult); grid on; axis tight;
    xlabel('WiFi Scan Location Index in Fingerprint Database'); ylabel('Reward Metric');
    
    
    % save images
    pause(0.01); refresh;
    saveImg = getframe(h_WiFi);
    imwrite(saveImg.cdata , sprintf('figures/%06d.png', queryIdx));
end


%% make .avi file from png files

movie = VideoWriter('myAVI.avi');
movie.FrameRate = 2; % set fps
open(movie);

for queryIdx = 1:numTestWiFiScan
    
    % read PNG image file
    filename = sprintf('figures/%06d.png', queryIdx);
    im = imread(filename);
    
    % write video
    writeVideo(movie, im);
    
    queryIdx
end

close(movie);





