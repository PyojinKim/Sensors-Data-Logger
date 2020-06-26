
%% temporary codes for Tango VIO ICP based optimization

% between (0) and (1)
testRoninIndex = [1 8 9 16 26 27 39 40 48];
numRoninData = size(testRoninIndex,2);


% define model Tango VIO trajectories
k = testRoninIndex(1);
TangoVIO = datasetTangoVIO{k};
model = [TangoVIO.location];


% ICP optimization
for k = testRoninIndex
    
    % current Tango VIO data
    TangoVIO = datasetTangoVIO{k};
    data = [TangoVIO.location];
    
    
    % run the ICP-algorithm. Least squares criterion
    [~,~,dataOut] = icp(model,data,[],[],1);
    for m = 1:size(TangoVIO,2)
        TangoVIO(m).location = dataOut(:,m);
    end
    datasetTangoVIO{k} = TangoVIO;
end


% ICP optimized Tango VIO visualization
for k = testRoninIndex
    
    % current Tango VIO data
    TangoVIO = datasetTangoVIO{k};
    TangoVIOLocation = [TangoVIO.location];
    
    
    % plot Tango VIO location
    distinguishableColors = distinguishable_colors(numDatasetList);
    figure(10); hold on; grid on; axis equal; axis tight;
    plot(TangoVIOLocation(1,:),TangoVIOLocation(2,:),'-','color',distinguishableColors(k,:),'LineWidth',1.5); grid on; axis equal;
    xlabel('X [m]','FontName','Times New Roman','FontSize',15);
    ylabel('Y [m]','FontName','Times New Roman','FontSize',15);
    set(gcf,'Units','pixels','Position',[150 60 1700 900]);  % modify figure
end


%%
















































