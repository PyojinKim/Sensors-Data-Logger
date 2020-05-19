
%% temporary codes for WiFi similarity based optimization

% between (1) and (2)
testRoninIndex = [2 7 17 22 25 41];
numRoninData = size(testRoninIndex,2);


% assign partial Tango VIO same trajectories
partialTangoVIO = cell(1,numRoninData);
count = 0;
for k = testRoninIndex
    count = count + 1;
    partialTangoVIO{count} = datasetTangoVIO{k};
end


% find the most similar WiFi RSSI vector
queryTangoRSSI = [partialTangoVIO{1}.RSSI];
partialTangoVIO{1}(1).WiFiIndex = [];
for n = 2:numRoninData
    
    testTangoRSSI = [partialTangoVIO{n}.RSSI];
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
            partialTangoVIO{1}(k).WiFiIndex = [partialTangoVIO{1}(k).WiFiIndex, maxRewardIndex];
        end
    end
end


% add query RSSI index
for k = 1:size(partialTangoVIO{1},2)
    if (~isempty(partialTangoVIO{1}(k).WiFiIndex))
        partialTangoVIO{1}(k).WiFiIndex = [k, partialTangoVIO{1}(k).WiFiIndex];
    end
end


%% (1) measurements (constants)

% traditional measurements
sensorMeasurements = cell(1,numRoninData);
isOffsetInitialized = false;
for k = 1:numRoninData
    
    % current Tango VIO data
    TangoVIO = partialTangoVIO{k};
    
    
    % Tango VIO constraints (relative movement)
    TangoPolarVIO = convertTangoVIOPolarCoordinate(TangoVIO);
    numTangoVIO = size(TangoPolarVIO,2);
    
    
    % Google FLP constraints (global location)
    TangoGoogleFLPIndex = [];
    for m = 1:numTangoVIO
        if (~isempty(TangoVIO(m).FLPLocationMeter))
            TangoGoogleFLPIndex = [TangoGoogleFLPIndex, m];
        end
    end
    TangoGoogleFLPLocation = [TangoVIO.FLPLocationMeter];
    
    
    % Google FLP offset for 2D rigid body rotation
    if (~isOffsetInitialized)
        isOffsetInitialized = true;
        offset = TangoGoogleFLPLocation(:,1);
    end
    TangoGoogleFLPLocation = TangoGoogleFLPLocation - offset;
    
    
    % sensor measurements from Tango VIO, Google FLP
    measurements.TangoPolarVIODistance = [TangoPolarVIO.distance];
    measurements.TangoPolarVIOAngle = [TangoPolarVIO.angle];
    measurements.TangoGoogleFLPIndex = TangoGoogleFLPIndex;
    measurements.TangoGoogleFLPLocation = TangoGoogleFLPLocation;
    measurements.TangoGoogleFLPAccuracy = [TangoVIO.FLPAccuracyMeter];
    sensorMeasurements{k} = measurements;
end


% construct WiFi constraints
WiFiSimilarityIndex = [];
for k = 1:size(partialTangoVIO{1},2)
    if (~isempty(partialTangoVIO{1}(k).WiFiIndex))
        WiFiSimilarityIndex = [WiFiSimilarityIndex; partialTangoVIO{1}(k).WiFiIndex];
    end
end
WiFiSimilarityRadius = 7.0;


%% (2) model parameters (variables) for Tango VIO drift correction model

% initialize Tango VIO drift correction model parameters
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
    
    
    % Tango VIO drift correction model
    startLocation = X_optimized((3*k-2):(3*k-1)).';
    rotation = X_optimized(3*k);
    numTangoVIO = size(TangoPolarVIODistance,2);
    scale = ones(1,numTangoVIO);
    bias = zeros(1,numTangoVIO);
    TangoVIOLocation = DriftCorrectedTangoVIOAbsoluteAngleModel(startLocation, rotation, scale, bias, TangoPolarVIODistance, TangoPolarVIOAngle);
    TangoVIOLocationSave{k} = TangoVIOLocation;
    
    
    % plot Tango VIO location
    distinguishableColors = distinguishable_colors(numDatasetList);
    figure(10); hold on; grid on; axis equal; axis tight;
    plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'-','color',distinguishableColors(k,:),'LineWidth',1.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure
end


%% WiFi raw matches visualization

%
TangoVIO = partialTangoVIO{1};


%
count = 0;
h_WiFi = figure(10);
for k = 1:size(TangoVIO,2)
    
    cla;
    
    
    % plot Tango VIO trajectories
    for n = 1:numRoninData
        
        % current Tango VIO data
        TangoVIO = partialTangoVIO{n};
        TangoVIOLocation = [TangoVIO.location];
        
        % plot Tango VIO location
        distinguishableColors = distinguishable_colors(numDatasetList);
        plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'-','color',distinguishableColors(n,:),'LineWidth',1.5); hold on; grid on; axis equal;
        xlabel('X [m]','FontName','Times New Roman','FontSize',15);
        ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    end
    
    
    % plot WiFi frames on Tango VIO trajectories
    for n = 1:numRoninData
        
        % current Tango VIO RSSI data
        TangoVIO = partialTangoVIO{n};
        TangoVIOofRSSI = [TangoVIO.RSSI];
        for m = 1:size(TangoVIOofRSSI,2)
            RSSI = TangoVIOofRSSI(:,m);
            if (sum(RSSI == -200) == 1179)
                continue;
            else
                scatter(TangoVIO(m).location(1),TangoVIO(m).location(2),150,'k.');
            end
        end
    end
    
    
    % plot WiFi raw match results
    TangoVIO = partialTangoVIO{1};
    if (~isempty(TangoVIO(k).WiFiIndex))
        
        % plot WiFi uncertainty radius on current location
        centerLocation = TangoVIO(k).location;
        plot_uncertainty_radius(centerLocation, 10.0, 'r', 2.0);
        
        
        % plot WiFi matching results
        WiFiIndex = TangoVIO(k).WiFiIndex;
        for m = 2:numRoninData
            
            % 2D query and estimated location
            queryLocation = TangoVIO(k).location;
            estimatedLocation = partialTangoVIO{m}(WiFiIndex(m)).location;
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
for k = 1:size(TangoVIO,2)
    
    cla;
    for n = 1:numRoninData
        
        % current Tango VIO data
        TangoVIO = partialTangoVIO{n};
        TangoVIOLocation = [TangoVIO.location];
        
        % plot Tango VIO location
        distinguishableColors = distinguishable_colors(numDatasetList);
        plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'-','color',distinguishableColors(n,:),'LineWidth',0.5); hold on; grid on; axis equal;
        xlabel('X [m]','FontName','Times New Roman','FontSize',15);
        ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    end
    
    
    % check WiFi scan RSSI exist or not
    TangoVIO = partialTangoVIO{1};
    if (~isempty(TangoVIO(k).WiFiIndex))
        
        WiFiIndex = TangoVIO(k).WiFiIndex;
        for m = 2:numRoninData
            
            % 2D query and estimated location
            queryLocation = TangoVIO(k).location;
            estimatedLocation = partialTangoVIO{m}(WiFiIndex(m-1)).location;
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
