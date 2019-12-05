clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;


%% common setting to read text files

delimiter = ' ';
headerlinesIn = 1;
nanoSecondToSecond = 1000000000;


%% 1) parse Tango 6-DoF sensor pose data

% parsing Tango sensor pose data text file
textTangoPoseData = importdata('pose.txt', delimiter, headerlinesIn);
poseTime = textTangoPoseData.data(:,1).';
poseTime = poseTime ./ nanoSecondToSecond;
poseRotation = textTangoPoseData.data(:,[5 2 3 4]).';
poseTranslation = textTangoPoseData.data(:,[6 7 8]).';

% Tango sensor pose with various 6-DoF sensor pose representations
numPose = size(poseRotation,2);
R_gb_Tango = zeros(3,3,numPose);
T_gb_Tango = cell(1,numPose);
stateEsti_Tango = zeros(6,numPose);
for k = 1:numPose
    
    % rigid body transformation matrix (4x4) (rotation matrix SO(3) from quaternion)
    R_gb_Tango(:,:,k) = q2r(poseRotation(:,k));
    T_gb_Tango{k} = [R_gb_Tango(:,:,k), poseTranslation(:,k); [0, 0, 0, 1]];
    
    % state vector and rotation matrix
    stateEsti_Tango(1:3,k) = T_gb_Tango{k}(1:3,4);
    [yaw, pitch, roll] = dcm2angle(R_gb_Tango(:,:,k));
    stateEsti_Tango(4:6,k) = [roll; pitch; yaw];
end

% plot update rate of Tango sensor pose
timeDifference = diff(poseTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(poseTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(poseTime) max(poseTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% play 3D trajectory of Tango sensor pose
figure(10);
for k = 1:10:numPose
    figure(10); cla;
    
    % draw moving trajectory
    p_gb_Tango = stateEsti_Tango(1:3,1:k);
    plot3(p_gb_Tango(1,:), p_gb_Tango(2,:), p_gb_Tango(3,:), 'm', 'LineWidth', 2); hold on; grid on; axis equal;
    
    % draw sensor body and frame
    plot_inertial_frame(0.5);
    Rgb_Tango_current = T_gb_Tango{k}(1:3,1:3);
    pgb_Tango_current = T_gb_Tango{k}(1:3,4);
    plot_sensor_Tango_frame(Rgb_Tango_current, pgb_Tango_current, 0.5, 'm');
    refresh; pause(0.01); k
end


%% 2) parse gravity vector

% parsing gravity text
textGravityData = importdata('gravity.txt', delimiter, headerlinesIn);
gravityTime = textGravityData.data(:,1).';
gravityTime = gravityTime ./ nanoSecondToSecond;
gravityData = textGravityData.data(:,[2 3 4]).';

% plot gravity vector X-Y-Z
figure;
subplot(3,1,1);
plot(gravityTime, gravityData(1,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(gravityTime) max(gravityTime) min(gravityData(1,:)) max(gravityData(1,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('X [m/s-2]','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(gravityTime, gravityData(2,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(gravityTime) max(gravityTime) min(gravityData(2,:)) max(gravityData(2,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Y [m/s-2]','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(gravityTime, gravityData(3,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(gravityTime) max(gravityTime) min(gravityData(3,:)) max(gravityData(3,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Z [m/s-2]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% plot gravity vector update rate
timeDifference = diff(gravityTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(gravityTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(gravityTime) max(gravityTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%% 3) synchronize Tango and gravity vector

% define reference time and data
startTime = max([poseTime(1), gravityTime(1)]);
poseTime = poseTime - startTime;
gravityTime = gravityTime - startTime;
endTime = max([poseTime(end), gravityTime(end)]);

timeInterval = 0.02;
syncTimestamp = [0.001:timeInterval:endTime];
numData = size(syncTimestamp,2);


% synchronize Tango, gravity vector
syncTangoPose = cell(1,numData);
syncTangoTrajectory = zeros(6,numData);
syncGravity = zeros(3,numData);
for k = 1:numData
    
    % remove future timestamp
    currentTime = syncTimestamp(k);
    validIndexTango = ((currentTime - poseTime) > 0);
    validIndexGravity = ((currentTime - gravityTime) > 0);
    timestampTango = poseTime(validIndexTango);
    timestampGravity = gravityTime(validIndexGravity);
    
    % Tango
    [~,indexTango] = min(abs(currentTime - timestampTango));
    syncTangoPose{k} = T_gb_Tango{indexTango};
    syncTangoTrajectory(:,k) =  stateEsti_Tango(:,indexTango);
    
    % gravity
    [~,indexGravity] = min(abs(currentTime - timestampGravity));
    syncGravity(:,k) = gravityData(:,indexGravity);
    
    % display current status
    fprintf('Current Status: %d / %d \n', k, numData);
end


% play synchronized Tango / gravity vector
h = figure(10);
set(gcf,'color','w'); axis equal; axis off;
set(gcf,'Units','pixels','Position',[800 150 800 800]);
for k = 1:numData
    
    % initialize the figure
    cla;
    
    
    % current Tango and gravity vector
    R_gb_Tango_current = syncTangoPose{k}(1:3,1:3);
    p_gb_Tango_current = syncTangoPose{k}(1:3,4);
    p_gb_Tango = syncTangoTrajectory(1:3,1:k);
    
    gravity_current = R_gb_Tango_current * syncGravity(:,k);
    gravity_current = -gravity_current / norm(gravity_current);
    gravity_current = p_gb_Tango_current + gravity_current;
    
    
    % plot Tango 3D trajectory
    plot3(p_gb_Tango(1,:), p_gb_Tango(2,:), p_gb_Tango(3,:), 'm', 'LineWidth', 2); hold on; grid on; axis equal;
    
    
    % plot Tango sensor frame
    plot_sensor_Tango_frame(R_gb_Tango_current, p_gb_Tango_current, 0.5, 'm');
    
    
    % plot gravity vector
    mArrow3(p_gb_Tango_current, gravity_current, 'color', 'red', 'stemWidth', 0.01);
    
    
    % figure options
    plot_inertial_frame(0.5);                               % global (inertial) frame
    view(-47,28);                                             % viewpoint angle
    xlabel('X [m]'); ylabel('Y [m]'); zlabel('Z [m]');  % each axis label
    pause(0.01); refresh(h); k
    
    
    % save images
    saveImg = getframe(h);
    imwrite(saveImg.cdata , sprintf('figures/%06d.png',k));
end



