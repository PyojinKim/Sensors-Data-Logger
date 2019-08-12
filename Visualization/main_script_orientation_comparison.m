clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;


%% common setting to read text files

% default setting for parsing text files
delimiter = ' ';
headerlinesIn = 1;
nanoSecondToSecond = 1000000000;


% parsing device orientation (IMU) text
textFileDir = 'game_rv_test.txt';
textOrientationData = importdata(textFileDir, delimiter, headerlinesIn);
deviceOrientationTime = textOrientationData.data(:,1).';
deviceOrientationData = textOrientationData.data(:,[5 2 3 4]).';
numIMUData = size(deviceOrientationData,2);


% parsing ARKit camera pose data text
textFileDir = 'ARKit_pose_test.txt';
textARKitPoseData = importdata(textFileDir, delimiter, headerlinesIn);
ARKitTime = textARKitPoseData.data(:,1).';
ARKitPose = textARKitPoseData.data(:,[2:13]);
numARKitData = size(ARKitPose,1);


% time synchronization
if (ARKitTime(1) < deviceOrientationTime(1))
    startTime = ARKitTime(1);
else
    startTime = deviceOrientationTime(1);
end
deviceOrientationTime = (deviceOrientationTime - startTime) ./ nanoSecondToSecond;
ARKitTime = (ARKitTime - startTime) ./ nanoSecondToSecond;


%% 1) device orientation from IMU

% convert from unit quaternion to rotation matrix & roll/pitch/yaw
R_gi_i = zeros(3,3,numIMUData);
rpy_gi_i = zeros(3,numIMUData);
for k = 1:numIMUData
    R_gi_i(:,:,k) = q2r(deviceOrientationData(:,k));
    rpy_gi_i(:,k) = rotmtx2angle(inv(R_gi_i(:,:,k)));
end

% play 3-DoF device orientation from IMU
figure(10);
L = 1; % coordinate axis length
A = [0 0 0 1; L 0 0 1; 0 0 0 1; 0 L 0 1; 0 0 0 1; 0 0 L 1].';
for k = 1:3:numIMUData
    cla;
    figure(10);
    plot_inertial_frame(0.5); hold on; grid on; axis equal;
    T_gi_i = [R_gi_i(:,:,k), ones(3,1);
        zeros(1,3), 1];
    B = T_gi_i * A;
    plot3(B(1,1:2),B(2,1:2),B(3,1:2),'-r','LineWidth',1);   % x: red
    plot3(B(1,3:4),B(2,3:4),B(3,3:4),'-g','LineWidth',1);  % y: green
    plot3(B(1,5:6),B(2,5:6),B(3,5:6),'-b','LineWidth',1);  % z: blue
    refresh; pause(0.01); k
end


%% 2) device orientation from ARKit camera pose

% ARKit camera pose with various 6-DoF camera pose representations
T_gc_c_ARKit = cell(1,numARKitData);
stateEsti_ARKit = zeros(6,numARKitData);
R_gc_c_ARKit = zeros(3,3,numARKitData);
for k = 1:numARKitData
    
    % rigid body transformation matrix (4x4)
    T_gc_c_ARKit{k} = [reshape(ARKitPose(k,:).', 4, 3).'; [0, 0, 0, 1]];
    
    % state vector and rotation matrix
    R_gc_c_ARKit(:,:,k) = T_gc_c_ARKit{k}(1:3,1:3);
    stateEsti_ARKit(1:3,k) = T_gc_c_ARKit{k}(1:3,4);
    [yaw, pitch, roll] = dcm2angle(R_gc_c_ARKit(:,:,k));
    stateEsti_ARKit(4:6,k) = [roll; pitch; yaw];
end

% play 3-DoF device orientation from ARKit camera pose
figure(10);
L = 1; % coordinate axis length
A = [0 0 0 1; L 0 0 1; 0 0 0 1; 0 L 0 1; 0 0 0 1; 0 0 L 1].';
for k = 1:2:numARKitData
    cla;
    figure(10);
    plot_inertial_frame(0.5); hold on; grid on; axis equal;
    T_gc_c = [R_gc_c_ARKit(:,:,k), ones(3,1);
        zeros(1,3), 1];
    B = T_gc_c * A;
    plot3(B(1,1:2),B(2,1:2),B(3,1:2),'-r','LineWidth',1);   % x: red
    plot3(B(1,3:4),B(2,3:4),B(3,3:4),'-g','LineWidth',1);  % y: green
    plot3(B(1,5:6),B(2,5:6),B(3,5:6),'-b','LineWidth',1);  % z: blue
    refresh; pause(0.01); k
end


%% 3) global / IMU / camera frame alignment

% camera-IMU frame alignment
R_ci = inv(angle2rotmtx([0; 0; pi/2]));
R_gc_i = zeros(3,3,numARKitData);
for k = 1:numARKitData
    R_gc_i(:,:,k) = R_gc_c_ARKit(:,:,k) * R_ci;
end


% synchronize the device orientation data between IMU and ARKit
timeSyncThreshold = 0.01;
deviceOrientationTime_sync = zeros(1,numARKitData);
R_gc_i_sync = zeros(3,3,numARKitData);
R_gi_i_sync = zeros(3,3,numARKitData);
count = 0;
for kARKit = 1:numARKitData
    
    % find the closest time in IMU data
    currentARKitTime = ARKitTime(kARKit);
    [minTimeDifference, kIMU] = min(abs(deviceOrientationTime - currentARKitTime));
    if (minTimeDifference <= timeSyncThreshold)
        
        % save the synchronized IMU, ARKit data
        count = count + 1;
        deviceOrientationTime_sync(count) = currentARKitTime;
        R_gc_i_sync(:,:,count) = R_gc_i(:,:,kARKit);
        R_gi_i_sync(:,:,count) = R_gi_i(:,:,kIMU);
    end
end
numSyncData = count;
deviceOrientationTime_sync(numSyncData+1:end) = [];
R_gc_i_sync(:,:,(numSyncData+1:end)) = [];
R_gi_i_sync(:,:,(numSyncData+1:end)) = [];


% SE(3) transformation between {gi} and {gc}
R_gi_gc = zeros(3,3,numSyncData);
rpy_gi_gc = zeros(3,numSyncData);
for k = 1:numSyncData
    R_gi_gc(:,:,k) = R_gi_i_sync(:,:,k) * inv(R_gc_i_sync(:,:,k));
    rpy_gi_gc(:,k) = rotmtx2angle(inv(R_gi_gc(:,:,k)));
end

% plot roll/pitch/yaw of device orientation
figure;
subplot(3,1,1);
plot(deviceOrientationTime_sync, rpy_gi_gc(1,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime_sync) max(deviceOrientationTime_sync) min(rpy_gi_gc(1,:)) max(rpy_gi_gc(1,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Roll [rad]','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(deviceOrientationTime_sync, rpy_gi_gc(2,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime_sync) max(deviceOrientationTime_sync) min(rpy_gi_gc(2,:)) max(rpy_gi_gc(2,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Pitch [rad]','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(deviceOrientationTime_sync, rpy_gi_gc(3,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime_sync) max(deviceOrientationTime_sync) min(rpy_gi_gc(3,:)) max(rpy_gi_gc(3,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Yaw [rad]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


% transform from ARKit global frame {gc} to IMU global frame {gi}
R_gi_gc_const = R_gi_gc(:,:,600);
R_gi_i_sync_fromARKit = zeros(3,3,numSyncData);
for k = 1:numSyncData
    R_gi_i_sync_fromARKit(:,:,k) = R_gi_gc_const * R_gc_i_sync(:,:,k);
end


%% 4) compare device orientation accuracy (IMU vs ARKit)

% convert to roll, pitch, yaw representations
rpy_gi_i_sync = zeros(3,numSyncData);
rpy_gi_i_sync_fromARKit = zeros(3,numSyncData);
for k = 1:numSyncData
    rpy_gi_i_sync(:,k) = rotmtx2angle(inv(R_gi_i_sync(:,:,k)));
    rpy_gi_i_sync_fromARKit(:,k) = rotmtx2angle(inv(R_gi_i_sync_fromARKit(:,:,k)));
end

% plot roll/pitch/yaw of device orientation
figure;
subplot(3,1,1);
plot(deviceOrientationTime_sync, rpy_gi_i_sync(1,:), 'm'); hold on; grid on;
plot(deviceOrientationTime_sync, rpy_gi_i_sync_fromARKit(1,:), 'k'); axis tight;
set(gcf,'color','w'); hold off; legend('IMU','ARKit');
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Roll [rad]','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(deviceOrientationTime_sync, rpy_gi_i_sync(2,:), 'm'); hold on; grid on;
plot(deviceOrientationTime_sync, rpy_gi_i_sync_fromARKit(2,:), 'k'); axis tight;
set(gcf,'color','w'); hold off;
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Pitch [rad]','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(deviceOrientationTime_sync, rpy_gi_i_sync(3,:), 'm'); hold on; grid on;
plot(deviceOrientationTime_sync, rpy_gi_i_sync_fromARKit(3,:), 'k'); axis tight;
set(gcf,'color','w'); hold off;
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Yaw [rad]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% play 3-DoF device orientation
figure(10);
L = 1; % coordinate axis length
A = [0 0 0 1; L 0 0 1; 0 0 0 1; 0 L 0 1; 0 0 0 1; 0 0 L 1].';
for k = 1:2:numSyncData
    cla;
    figure(10);
    plot_inertial_frame(0.5); hold on; grid on; axis equal;
    T_gi = [R_gi_i_sync(:,:,k), 1.1*ones(3,1);
        zeros(1,3), 1];
    B = T_gi * A;
    plot3(B(1,1:2),B(2,1:2),B(3,1:2),'-r','LineWidth',1);   % x: red
    plot3(B(1,3:4),B(2,3:4),B(3,3:4),'-g','LineWidth',1);  % y: green
    plot3(B(1,5:6),B(2,5:6),B(3,5:6),'-b','LineWidth',1);  % z: blue
    
    T_gi = [R_gi_i_sync_fromARKit(:,:,k), ones(3,1);
        zeros(1,3), 1];
    B = T_gi * A;
    plot3(B(1,1:2),B(2,1:2),B(3,1:2),'-r','LineWidth',3);   % x: red
    plot3(B(1,3:4),B(2,3:4),B(3,3:4),'-g','LineWidth',3);  % y: green
    plot3(B(1,5:6),B(2,5:6),B(3,5:6),'-b','LineWidth',3);  % z: blue
    refresh; pause(0.01); k
end



