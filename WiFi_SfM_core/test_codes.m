

queryRSSI = wifiScanRSSI(20).RSSI;



numWiFiScan = size(wifiScanRSSI,2);
distanceResult = 50 * ones(1,numWiFiScan);
numUniqueAPs = size(queryRSSI,1);
for k = 1:numWiFiScan
    
    %
    testRSSI = wifiScanRSSI(k).RSSI;
    distanceSum = 0;
    distanceCount = 0;
    for m = 1:numUniqueAPs
        
        % compute the difference
        a = queryRSSI(m);
        b = testRSSI(m);
        if ((a ~= -200) && (b ~= -200))
            %distanceSum = distanceSum + ((a - b)^2);    % L2 distance
            distanceSum = distanceSum + abs(a - b);        % L1 distance
            distanceCount = distanceCount + 1;
        end
    end
    
    % save the average distance metric
    if ((distanceCount ~= 0) && (distanceCount > 5))
        %distanceResult(k) = sqrt(distanceSum / distanceCount);   % L2 distance
        distanceResult(k) = distanceSum / distanceCount;             % L1 distance
    end
end



figure;
plot(distanceResult);
xlabel('WiFi Scan Location Index'); ylabel('Distance Metric (L1)');

[~,index] = min(distanceResult);



%%


% 1) plot Tango VIO motion estimation results
figure;
h_Tango = plot3(stateEsti_Tango(1,:),stateEsti_Tango(2,:),stateEsti_Tango(3,:),'k','LineWidth',2); hold on; grid on;
plot_inertial_frame(0.5); legend(h_Tango,{'Tango'}); axis equal; view(26, 73);
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); zlabel('z [m]','fontsize',10); hold off;

% figure options
f = FigureRotator(gca());











