%%


% parse all FLP.txt files
numDatasetList = size(datasetList,1);
datasetGoogleFLPResult = cell(1,numDatasetList);
for k = 8:numDatasetList
    
    % parse FLP.txt file
    FLPTextFile = [datasetPath '/' datasetList(k).name '/FLP.txt'];
    GoogleFLPResult = parseGoogleFLPTextFile(FLPTextFile);
    
    % save Google FLP result
    datasetGoogleFLPResult{k} = GoogleFLPResult;
end

%%


k = 10;
GoogleLocationDegree = [GoogleFLPResult(:).locationDegree];
GoogleLocationMeter = [GoogleFLPResult(:).locationMeter];
temp = [TangoPoseResult(:).stateEsti_Tango];


% plot horizontal position (latitude / longitude) trajectory on Google map
figure;
plot(GoogleLocationDegree(2,:), GoogleLocationDegree(1,:), 'b*-', 'LineWidth', 1); hold on;
plot_google_map('maptype', 'roadmap', 'APIKey', 'AIzaSyB_uD1rGjX6MJkoQgSDyjHkbdu-b-_5Bjg');
xlabel('Longitude [deg]','FontName','Times New Roman','FontSize',17);
ylabel('Latitude [deg]','FontName','Times New Roman','FontSize',17);



%
yaw = 68;
R = angle2rotmtx([0;0;(deg2rad(yaw))]);
R = R(1:2,1:2);
t = GoogleFLPResult(1).location(1:2);


% transform to global inertial frame
numGoogleFLP = size(GoogleFLPResult,2);
for m = 1:numGoogleFLP
    GoogleLocationMeterTransformed = (R * GoogleFLPResult(m).locationMeter + t);
    GoogleFLPResult(m).locationMeter = GoogleLocationMeterTransformed;
end


% plot 3D arrow location error
trueTrajectory = [GoogleFLPResult(:).location];
FLPTrajectory = [GoogleFLPResult(:).locationMeter];
figure;
h_true = plot(trueTrajectory(1,:),trueTrajectory(2,:),'k*-','LineWidth',1.0); hold on; grid on;
h_WiFi = plot(FLPTrajectory(1,:),FLPTrajectory(2,:),'m*-','LineWidth',1.0);
for k = 1:numGoogleFLP
    trueLocation = [GoogleFLPResult(k).location(1:2); 0];
    FLPLocation = [GoogleFLPResult(k).locationMeter(1:2); 0];
    mArrow3(trueLocation, FLPLocation, 'color', 'red', 'stemWidth', 0.04);
end
plot_inertial_frame(0.5); axis equal;
xlabel('x [m]'); ylabel('y [m]');



figure;
plot(temp(1,:),temp(2,:),'k-'); hold on; grid on; axis equal;
plot(GoogleLocationMeterTransformed(1,:),GoogleLocationMeterTransformed(2,:),'m*-');







%%


% current Tango VIO pose / WiFi RSSI vector
k = 10;
TangoPoseResult = datasetTangoPoseResult{k};
GoogleFLPResult = datasetGoogleFLPResult{k};

% label Google FLP result
numGoogleFLP = size(GoogleFLPResult,2);
for m = 1:numGoogleFLP
    
    % find the closest Tango pose timestamp
    [timeDifference, indexTango] = min(abs(GoogleFLPResult(m).timestamp - [TangoPoseResult.timestamp]));
    if (timeDifference < 1.0)
        
        % save corresponding Tango pose location
        GoogleFLPResult(m).location = TangoPoseResult(indexTango).stateEsti_Tango;
        GoogleFLPResult(m).dataset = datasetList(k).name;
    else
        error('Fail to find the closest Tango pose timestamp.... at %d', m);
    end
end





