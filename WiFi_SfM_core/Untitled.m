

%% temporary codes for WiFi similarity based optimization

% between (1) and (2)
testRoninIndex = [2 7 17 22 25 41];
numRoninData = size(testRoninIndex,2);


% assign partial Tango VIO trajectories
tempTangoVIO = cell(1,numRoninData);
count = 0;
for k = testRoninIndex
    count = count + 1;
    tempTangoVIO{count} = datasetTangoVIO{k};
end


% find the most similar WiFi RSSI vector
queryTangoRSSI = [tempTangoVIO{1}.RSSI];
tempTangoVIO{1}(1).WiFiIndex = [];
for n = 2:numRoninData
    
    testTangoRSSI = [tempTangoVIO{n}.RSSI];
    for k = 1:size(queryTangoRSSI,2)
        
        queryRSSI = queryTangoRSSI(:,k);
        
        if (sum(queryRSSI == -200) == 1179)
            continue;
        else
            
            % calculate reward function based on the RSSI vectors
            numTest = size(testTangoRSSI,2);
            rewardResult = zeros(1,numTest);
            for m = 1:numTest
                rewardResult(m) = computeRewardMetric(queryRSSI, testTangoRSSI(:,m));
            end
            [~,maxRewardIndex] = max(rewardResult);
            
            % save the result
            tempTangoVIO{1}(k).WiFiIndex = [tempTangoVIO{1}(k).WiFiIndex, maxRewardIndex];
        end
    end
end



%
h_WiFi = figure(10);
for k = 1:size(TangoVIO,2)
    
    cla;
    for n = 1:numRoninData
        
        % current Tango VIO data
        TangoVIO = tempTangoVIO{n};
        TangoVIOLocation = [TangoVIO.location];
        
        % plot Tango VIO location
        distinguishableColors = distinguishable_colors(numDatasetList);
        plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'-','color',distinguishableColors(n,:),'LineWidth',0.5); hold on; grid on; axis equal;
        xlabel('X [m]','FontName','Times New Roman','FontSize',15);
        ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    end
    
    
    % check WiFi scan RSSI exist or not
    TangoVIO = tempTangoVIO{1};
    if (~isempty(TangoVIO(k).WiFiIndex))
        
        WiFiIndex = TangoVIO(k).WiFiIndex;
        for m = 2:numRoninData
            
            % 2D query and estimated location
            queryLocation = TangoVIO(k).location;
            estimatedLocation = tempTangoVIO{m}(WiFiIndex(m-1)).location;
            errorLocation = norm(queryLocation - estimatedLocation);
            midPoint = (queryLocation + estimatedLocation) / 2;
            
            % plot current status
            line([queryLocation(1) estimatedLocation(1)], [queryLocation(2) estimatedLocation(2)],'color','k','LineWidth',2.5);
            scatter(queryLocation(1),queryLocation(2),800,'m.');
            scatter(estimatedLocation(1),estimatedLocation(2),800,'k.');
            text(midPoint(1)+0.2, midPoint(2)+0.2, 0, sprintf('%2.2f (m)', errorLocation),'Color','k','FontSize',11,'FontWeight','bold');
        end
    end
end











%%


%
% tempTangoRSSI = cell(1,numRoninData);
% for k = 1:numRoninData
%
%     tempRSSI = [];
%     TangoVIO = tempTangoVIO{k};
%     for m = 1:size(TangoVIO,2)
%          if (~isempty(TangoVIO(m).RSSI))
%
%
%          else
%
%          end
%
%
%     end
%
%
%
% end
