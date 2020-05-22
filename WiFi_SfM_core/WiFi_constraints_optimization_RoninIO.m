
%% temporary codes for WiFi similarity based optimization

% between (1) and (2)
testRoninIndex = [1 8 9 16 26 27 39 40 48];
numRoninData = size(testRoninIndex,2);


% assign partial RoNIN IO same trajectories
partialRoninIO = cell(1,numRoninData);
count = 0;
for k = testRoninIndex
    count = count + 1;
    partialRoninIO{count} = datasetRoninIO{k};
end


% find the most similar WiFi RSSI vector
queryRoninRSSI = [partialRoninIO{1}.RSSI];
partialRoninIO{1}(1).WiFiIndex = [];
for n = 2:numRoninData
    
    testRoninRSSI = [partialRoninIO{n}.RSSI];
    for k = 1:size(queryRoninRSSI,2)
        
        queryRSSI = queryRoninRSSI(:,k);
        
        if (sum(queryRSSI == -200) == 1179)
            continue;
        else
            
            % calculate reward function based on the RSSI vectors
            numTest = size(testRoninRSSI,2);
            rewardResult = zeros(1,numTest);
            for m = 1:numTest
                rewardResult(m) = computeRewardMetric(queryRSSI, testRoninRSSI(:,m));
            end
            [~,maxRewardIndex] = max(rewardResult);
            
            % save the result
            partialRoninIO{1}(k).WiFiIndex = [partialRoninIO{1}(k).WiFiIndex, maxRewardIndex];
        end
    end
end


% add query RSSI index
for k = 1:size(partialRoninIO{1},2)
    if (~isempty(partialRoninIO{1}(k).WiFiIndex))
        partialRoninIO{1}(k).WiFiIndex = [k, partialRoninIO{1}(k).WiFiIndex];
    end
end


%% (1) measurements (constants)

% traditional measurements
sensorMeasurements = cell(1,numRoninData);
isOffsetInitialized = false;
for k = 1:numRoninData
    
    % current RoNIN IO data
    RoninIO = partialRoninIO{k};
    
    
    % RoNIN IO constraints (relative movement)
    RoninPolarIO = convertRoninPolarCoordinate(RoninIO);
    numRoninIO = size(RoninPolarIO,2);
    
    
    % Google FLP constraints (global location)
    TangoGoogleFLPIndex = [];
    for m = 1:numRoninIO
        if (~isempty(RoninIO(m).FLPLocationMeter))
            TangoGoogleFLPIndex = [TangoGoogleFLPIndex, m];
        end
    end
    TangoGoogleFLPLocation = [RoninIO.FLPLocationMeter];
    
    
    % Google FLP offset for 2D rigid body rotation
    if (~isOffsetInitialized)
        isOffsetInitialized = true;
        offset = TangoGoogleFLPLocation(:,1);
    end
    TangoGoogleFLPLocation = TangoGoogleFLPLocation - offset;
    
    
    % sensor measurements from RoNIN IO, Google FLP
    measurements.TangoPolarVIODistance = [RoninPolarIO.distance];
    measurements.TangoPolarVIOAngle = [RoninPolarIO.angle];
    measurements.TangoGoogleFLPIndex = TangoGoogleFLPIndex;
    measurements.TangoGoogleFLPLocation = TangoGoogleFLPLocation;
    measurements.TangoGoogleFLPAccuracy = [RoninIO.FLPAccuracyMeter];
    sensorMeasurements{k} = measurements;
end


% construct WiFi constraints
WiFiSimilarityIndex = [];
for k = 1:size(partialRoninIO{1},2)
    if (~isempty(partialRoninIO{1}(k).WiFiIndex))
        WiFiSimilarityIndex = [WiFiSimilarityIndex; partialRoninIO{1}(k).WiFiIndex];
    end
end
WiFiSimilarityRadius = 7.0;


%% (2) model parameters (variables) for RoNIN IO drift correction model

% initialize RoNIN IO drift correction model parameters
X_initial = zeros(1,3*numRoninData);
for k = 1:numRoninData
    X_initial((3*k-2):(3*k-1)) = sensorMeasurements{k}.TangoGoogleFLPLocation(:,1).';
end


%% (3) nonlinear optimization

% run nonlinear optimization using lsqnonlin in Matlab (Levenberg-Marquardt)
options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt','Display','iter-detailed','MaxIterations',400);
[vec,resnorm,residuals,exitflag] = lsqnonlin(@(x) EuclideanDistanceResidual_Tango_GoogleFLP_WiFi(sensorMeasurements, WiFiSimilarityIndex, x),X_initial,[],[],options);
X_optimized = vec;


%
numRoninData = size(sensorMeasurements,2);
TangoVIOLocationSave = cell(1,numRoninData);
for k = 1:numRoninData
    
    % unpack sensor measurements
    TangoPolarVIODistance = sensorMeasurements{k}.TangoPolarVIODistance;
    TangoPolarVIOAngle = sensorMeasurements{k}.TangoPolarVIOAngle;
    
    
    % RoNIN IO drift correction model
    startLocation = X_optimized((3*k-2):(3*k-1)).';
    rotation = X_optimized(3*k);
    numRoninIO = size(TangoPolarVIODistance,2);
    scale = ones(1,numRoninIO);
    bias = zeros(1,numRoninIO);
    RoninIOLocation = DriftCorrectedTangoVIOAbsoluteAngleModel(startLocation, rotation, scale, bias, TangoPolarVIODistance, TangoPolarVIOAngle);
    TangoVIOLocationSave{k} = RoninIOLocation;
    
    
    % plot RoNIN IO location
    distinguishableColors = distinguishable_colors(numDatasetList);
    figure(10); hold on; grid on; axis equal; axis tight;
    plot(RoninIOLocation(1,:),RoninIOLocation(2,:),'-','color',distinguishableColors(k,:),'LineWidth',1.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure
end


%% WiFi raw matches visualization

%
RoninIO = partialRoninIO{1};


%
count = 0;
h_WiFi = figure(10);
for k = 1:size(RoninIO,2)
    
    cla;
    
    
    % plot RoNIN IO trajectories
    for n = 1:numRoninData
        
        % current RoNIN IO data
        RoninIO = partialRoninIO{n};
        RoninIOLocation = [RoninIO.location];
        
        % plot RoNIN IO location
        distinguishableColors = distinguishable_colors(numDatasetList);
        plot(RoninIOLocation(1,:),RoninIOLocation(2,:),'-','color',distinguishableColors(n,:),'LineWidth',1.5); hold on; grid on; axis equal;
        xlabel('X [m]','FontName','Times New Roman','FontSize',15);
        ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    end
    
    
    % plot WiFi frames on RoNIN IO trajectories
    for n = 1:numRoninData
        
        % current RoNIN IO RSSI data
        RoninIO = partialRoninIO{n};
        TangoVIOofRSSI = [RoninIO.RSSI];
        for m = 1:size(TangoVIOofRSSI,2)
            RSSI = TangoVIOofRSSI(:,m);
            if (sum(RSSI == -200) == 1179)
                continue;
            else
                scatter(RoninIO(m).location(1),RoninIO(m).location(2),150,'k.');
            end
        end
    end
    
    
    % plot WiFi raw match results
    RoninIO = partialRoninIO{1};
    if (~isempty(RoninIO(k).WiFiIndex))
        
        % plot WiFi uncertainty radius on current location
        centerLocation = RoninIO(k).location;
        plot_uncertainty_radius(centerLocation, 10.0, 'r', 2.0);
        
        
        % plot WiFi matching results
        WiFiIndex = RoninIO(k).WiFiIndex;
        for m = 2:numRoninData
            
            % 2D query and estimated location
            queryLocation = RoninIO(k).location;
            estimatedLocation = partialRoninIO{m}(WiFiIndex(m)).location;
            errorLocation = norm(queryLocation - estimatedLocation);
            midPoint = (queryLocation + estimatedLocation) / 2;
            
            % plot current status
            line([queryLocation(1) estimatedLocation(1)], [queryLocation(2) estimatedLocation(2)],'color','k','LineWidth',2.5);
            scatter(queryLocation(1),queryLocation(2),800,'m.');
            scatter(estimatedLocation(1),estimatedLocation(2),800,'k.');
            %text(midPoint(1)+0.2, midPoint(2)+0.2, 0, sprintf('%2.2f (m)', errorLocation),'Color','k','FontSize',11,'FontWeight','bold');
        end
        
        % save images
        count = count + 1;
        pause(0.01); refresh;
        saveImg = getframe(h_WiFi);
        imwrite(saveImg.cdata , sprintf('figures/%06d.png', count));
    end
end


%%



%
h_WiFi = figure(10);
for k = 1:size(RoninIO,2)
    
    cla;
    for n = 1:numRoninData
        
        % current RoNIN IO data
        RoninIO = partialRoninIO{n};
        RoninIOLocation = [RoninIO.location];
        
        % plot RoNIN IO location
        distinguishableColors = distinguishable_colors(numDatasetList);
        plot(RoninIOLocation(1,:),RoninIOLocation(2,:),'-','color',distinguishableColors(n,:),'LineWidth',0.5); hold on; grid on; axis equal;
        xlabel('X [m]','FontName','Times New Roman','FontSize',15);
        ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    end
    
    
    % check WiFi scan RSSI exist or not
    RoninIO = partialRoninIO{1};
    if (~isempty(RoninIO(k).WiFiIndex))
        
        WiFiIndex = RoninIO(k).WiFiIndex;
        for m = 2:numRoninData
            
            % 2D query and estimated location
            queryLocation = RoninIO(k).location;
            estimatedLocation = partialRoninIO{m}(WiFiIndex(m-1)).location;
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
