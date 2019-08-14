clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;


%% common setting to read text files

delimiter = ' ';
headerlinesIn = 1;
nanoSecondToSecond = 1000000000;


%% 1) device orientation (rotation vector)

% parsing device orientation text
textFileDir = 'rv.txt';
textOrientationData = importdata(textFileDir, delimiter, headerlinesIn);
deviceOrientationTime = textOrientationData.data(:,1).';
deviceOrientationTime = (deviceOrientationTime - deviceOrientationTime(1)) ./ nanoSecondToSecond;
deviceOrientationData = textOrientationData.data(:,[5 2 3 4]).';
numData = size(deviceOrientationData,2);

% convert from unit quaternion to rotation matrix & roll/pitch/yaw
R_gb = zeros(3,3,numData);
rpy_gb = zeros(3,numData);
for k = 1:numData
    R_gb(:,:,k) = q2r(deviceOrientationData(:,k));
    rpy_gb(:,k) = rotmtx2angle(inv(R_gb(:,:,k)));
end

% play 3-DoF device orientation
figure(10);
L = 1; % coordinate axis length
A = [0 0 0 1; L 0 0 1; 0 0 0 1; 0 L 0 1; 0 0 0 1; 0 0 L 1].';
for k = 1:5:numData
    figure(10); cla;
    plot_inertial_frame(0.5); hold on; grid on; axis equal;
    T_gb = [R_gb(:,:,k), ones(3,1);
        zeros(1,3), 1];
    B = T_gb * A;
    plot3(B(1,1:2),B(2,1:2),B(3,1:2),'-r','LineWidth',1);   % x: red
    plot3(B(1,3:4),B(2,3:4),B(3,3:4),'-g','LineWidth',1);  % y: green
    plot3(B(1,5:6),B(2,5:6),B(3,5:6),'-b','LineWidth',1);  % z: blue
    refresh; pause(0.01); k
end

% plot roll/pitch/yaw of device orientation
figure;
subplot(3,1,1);
plot(deviceOrientationTime, rpy_gb(1,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime) max(deviceOrientationTime) min(rpy_gb(1,:)) max(rpy_gb(1,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Roll [rad]','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(deviceOrientationTime, rpy_gb(2,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime) max(deviceOrientationTime) min(rpy_gb(2,:)) max(rpy_gb(2,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Pitch [rad]','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(deviceOrientationTime, rpy_gb(3,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime) max(deviceOrientationTime) min(rpy_gb(3,:)) max(rpy_gb(3,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Yaw [rad]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% plot update rate of device orientation
timeDifference = diff(deviceOrientationTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(deviceOrientationTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime) max(deviceOrientationTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%% 2) device orientation (game rotation vector)

% parsing device orientation text
textFileDir = 'game_rv.txt';
textOrientationData = importdata(textFileDir, delimiter, headerlinesIn);
deviceOrientationTime = textOrientationData.data(:,1).';
deviceOrientationTime = (deviceOrientationTime - deviceOrientationTime(1)) ./ nanoSecondToSecond;
deviceOrientationData = textOrientationData.data(:,[5 2 3 4]).';
numData = size(deviceOrientationData,2);

% convert from unit quaternion to rotation matrix & roll/pitch/yaw
R_gb = zeros(3,3,numData);
rpy_gb = zeros(3,numData);
for k = 1:numData
    R_gb(:,:,k) = q2r(deviceOrientationData(:,k));
    rpy_gb(:,k) = rotmtx2angle(inv(R_gb(:,:,k)));
end

% play 3-DoF device orientation
figure(10);
L = 1; % coordinate axis length
A = [0 0 0 1; L 0 0 1; 0 0 0 1; 0 L 0 1; 0 0 0 1; 0 0 L 1].';
for k = 1:5:numData
    figure(10); cla;
    plot_inertial_frame(0.5); hold on; grid on; axis equal;
    T_gb = [R_gb(:,:,k), ones(3,1);
        zeros(1,3), 1];
    B = T_gb * A;
    plot3(B(1,1:2),B(2,1:2),B(3,1:2),'-r','LineWidth',1);   % x: red
    plot3(B(1,3:4),B(2,3:4),B(3,3:4),'-g','LineWidth',1);  % y: green
    plot3(B(1,5:6),B(2,5:6),B(3,5:6),'-b','LineWidth',1);  % z: blue
    refresh; pause(0.01); k
end

% plot roll/pitch/yaw of device orientation
figure;
subplot(3,1,1);
plot(deviceOrientationTime, rpy_gb(1,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime) max(deviceOrientationTime) min(rpy_gb(1,:)) max(rpy_gb(1,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Roll [rad]','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(deviceOrientationTime, rpy_gb(2,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime) max(deviceOrientationTime) min(rpy_gb(2,:)) max(rpy_gb(2,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Pitch [rad]','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(deviceOrientationTime, rpy_gb(3,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime) max(deviceOrientationTime) min(rpy_gb(3,:)) max(rpy_gb(3,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Yaw [rad]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% plot update rate of device orientation
timeDifference = diff(deviceOrientationTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(deviceOrientationTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime) max(deviceOrientationTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%% 3) device orientation (geomagnetic rotation vector)

% parsing device orientation text
textFileDir = 'magnetic_rv.txt';
textOrientationData = importdata(textFileDir, delimiter, headerlinesIn);
deviceOrientationTime = textOrientationData.data(:,1).';
deviceOrientationTime = (deviceOrientationTime - deviceOrientationTime(1)) ./ nanoSecondToSecond;
deviceOrientationData = textOrientationData.data(:,[5 2 3 4]).';
numData = size(deviceOrientationData,2);

% convert from unit quaternion to rotation matrix & roll/pitch/yaw
R_gb = zeros(3,3,numData);
rpy_gb = zeros(3,numData);
for k = 1:numData
    R_gb(:,:,k) = q2r(deviceOrientationData(:,k));
    rpy_gb(:,k) = rotmtx2angle(inv(R_gb(:,:,k)));
end

% play 3-DoF device orientation
figure(10);
L = 1; % coordinate axis length
A = [0 0 0 1; L 0 0 1; 0 0 0 1; 0 L 0 1; 0 0 0 1; 0 0 L 1].';
for k = 1:5:numData
    figure(10); cla;
    plot_inertial_frame(0.5); hold on; grid on; axis equal;
    T_gb = [R_gb(:,:,k), ones(3,1);
        zeros(1,3), 1];
    B = T_gb * A;
    plot3(B(1,1:2),B(2,1:2),B(3,1:2),'-r','LineWidth',1);   % x: red
    plot3(B(1,3:4),B(2,3:4),B(3,3:4),'-g','LineWidth',1);  % y: green
    plot3(B(1,5:6),B(2,5:6),B(3,5:6),'-b','LineWidth',1);  % z: blue
    refresh; pause(0.01); k
end

% plot roll/pitch/yaw of device orientation
figure;
subplot(3,1,1);
plot(deviceOrientationTime, rpy_gb(1,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime) max(deviceOrientationTime) min(rpy_gb(1,:)) max(rpy_gb(1,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Roll [rad]','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(deviceOrientationTime, rpy_gb(2,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime) max(deviceOrientationTime) min(rpy_gb(2,:)) max(rpy_gb(2,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Pitch [rad]','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(deviceOrientationTime, rpy_gb(3,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime) max(deviceOrientationTime) min(rpy_gb(3,:)) max(rpy_gb(3,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Yaw [rad]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% plot update rate of device orientation
timeDifference = diff(deviceOrientationTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(deviceOrientationTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(deviceOrientationTime) max(deviceOrientationTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%% 4) raw acceleration

% parsing raw acceleration text
textFileDir = 'acce_uncalib.txt';
textRawAccelerationData = importdata(textFileDir, delimiter, headerlinesIn);
rawAccelTime = textRawAccelerationData.data(:,1).';
rawAccelTime = (rawAccelTime - rawAccelTime(1)) ./ nanoSecondToSecond;
rawAccelData = textRawAccelerationData.data(:,[2 3 4]).';

% plot raw acceleration X-Y-Z
figure;
subplot(3,1,1);
plot(rawAccelTime, rawAccelData(1,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(rawAccelTime) max(rawAccelTime) min(rawAccelData(1,:)) max(rawAccelData(1,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('X [m/s-2]','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(rawAccelTime, rawAccelData(2,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(rawAccelTime) max(rawAccelTime) min(rawAccelData(2,:)) max(rawAccelData(2,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Y [m/s-2]','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(rawAccelTime, rawAccelData(3,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(rawAccelTime) max(rawAccelTime) min(rawAccelData(3,:)) max(rawAccelData(3,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Z [m/s-2]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% plot raw acceleration update rate
timeDifference = diff(rawAccelTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(rawAccelTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(rawAccelTime) max(rawAccelTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%% 5) unbiased rotation rate

% parsing unbiased rotation rate text
textFileDir = 'gyro.txt';
textUnbiasedGyroData = importdata(textFileDir, delimiter, headerlinesIn);
unbiasedGyroTime = textUnbiasedGyroData.data(:,1).';
unbiasedGyroTime = (unbiasedGyroTime - unbiasedGyroTime(1)) ./ nanoSecondToSecond;
unbiasedGyroData = textUnbiasedGyroData.data(:,[2 3 4]).';

% plot unbiased rotation rate X-Y-Z
figure;
subplot(3,1,1);
plot(unbiasedGyroTime, unbiasedGyroData(1,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(unbiasedGyroTime) max(unbiasedGyroTime) min(unbiasedGyroData(1,:)) max(unbiasedGyroData(1,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('X [rad/s]','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(unbiasedGyroTime, unbiasedGyroData(2,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(unbiasedGyroTime) max(unbiasedGyroTime) min(unbiasedGyroData(2,:)) max(unbiasedGyroData(2,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Y [rad/s]','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(unbiasedGyroTime, unbiasedGyroData(3,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(unbiasedGyroTime) max(unbiasedGyroTime) min(unbiasedGyroData(3,:)) max(unbiasedGyroData(3,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Z [rad/s]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% plot unbiased rotation rate update rate
timeDifference = diff(unbiasedGyroTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(unbiasedGyroTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(unbiasedGyroTime) max(unbiasedGyroTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%% 6) raw rotation rate

% parsing raw rotation rate text
textFileDir = 'gyro_uncalib.txt';
textRawGyroData = importdata(textFileDir, delimiter, headerlinesIn);
rawGyroTime = textRawGyroData.data(:,1).';
rawGyroTime = (rawGyroTime - rawGyroTime(1)) ./ nanoSecondToSecond;
rawGyroData = textRawGyroData.data(:,[2 3 4]).';

% plot raw rotation rate X-Y-Z
figure;
subplot(3,1,1);
plot(rawGyroTime, rawGyroData(1,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(rawGyroTime) max(rawGyroTime) min(rawGyroData(1,:)) max(rawGyroData(1,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('X [rad/s]','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(rawGyroTime, rawGyroData(2,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(rawGyroTime) max(rawGyroTime) min(rawGyroData(2,:)) max(rawGyroData(2,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Y [rad/s]','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(rawGyroTime, rawGyroData(3,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(rawGyroTime) max(rawGyroTime) min(rawGyroData(3,:)) max(rawGyroData(3,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Z [rad/s]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% plot raw rotation rate update rate
timeDifference = diff(rawGyroTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(rawGyroTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(rawGyroTime) max(rawGyroTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%% 7) user-generated acceleration vector

% parsing user-generated acceleration text
textFileDir = 'linacce.txt';
textUserAccelerationData = importdata(textFileDir, delimiter, headerlinesIn);
userAccelTime = textUserAccelerationData.data(:,1).';
userAccelTime = (userAccelTime - userAccelTime(1)) ./ nanoSecondToSecond;
userAccelData = textUserAccelerationData.data(:,[2 3 4]).';

% plot user-generated acceleration vector X-Y-Z
figure;
subplot(3,1,1);
plot(userAccelTime, userAccelData(1,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(userAccelTime) max(userAccelTime) min(userAccelData(1,:)) max(userAccelData(1,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('X [m/s-2]','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(userAccelTime, userAccelData(2,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(userAccelTime) max(userAccelTime) min(userAccelData(2,:)) max(userAccelData(2,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Y [m/s-2]','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(userAccelTime, userAccelData(3,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(userAccelTime) max(userAccelTime) min(userAccelData(3,:)) max(userAccelData(3,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Z [m/s-2]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% plot user-generated acceleration vector update rate
timeDifference = diff(userAccelTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(userAccelTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(userAccelTime) max(userAccelTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%% 8) gravity vector

% parsing gravity text
textFileDir = 'gravity.txt';
textGravityData = importdata(textFileDir, delimiter, headerlinesIn);
gravityTime = textGravityData.data(:,1).';
gravityTime = (gravityTime - gravityTime(1)) ./ nanoSecondToSecond;
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


%% 9) calibrated magnetic field

% parsing calibrated magnetic field text
textFileDir = 'magnet.txt';
textMagnetData = importdata(textFileDir, delimiter, headerlinesIn);
magnetTime = textMagnetData.data(:,1).';
magnetTime = (magnetTime - magnetTime(1)) ./ nanoSecondToSecond;
magnetData = textMagnetData.data(:,[2 3 4]).';

% plot calibrated magnetic field X-Y-Z
figure;
subplot(3,1,1);
plot(magnetTime, magnetData(1,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(magnetTime) max(magnetTime) min(magnetData(1,:)) max(magnetData(1,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('X [microT]','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(magnetTime, magnetData(2,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(magnetTime) max(magnetTime) min(magnetData(2,:)) max(magnetData(2,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Y [microT]','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(magnetTime, magnetData(3,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(magnetTime) max(magnetTime) min(magnetData(3,:)) max(magnetData(3,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Z [microT]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% plot calibrated magnetic field update rate
timeDifference = diff(magnetTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(magnetTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(magnetTime) max(magnetTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%% 10) raw magnetic field

% parsing raw magnetic field text
textFileDir = 'magnet_uncalib.txt';
textRawMagnetData = importdata(textFileDir, delimiter, headerlinesIn);
rawMagnetTime = textRawMagnetData.data(:,1).';
rawMagnetTime = (rawMagnetTime - rawMagnetTime(1)) ./ nanoSecondToSecond;
rawMagnetData = textRawMagnetData.data(:,[2 3 4]).';

% plot raw magnetic field X-Y-Z
figure;
subplot(3,1,1);
plot(rawMagnetTime, rawMagnetData(1,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(rawMagnetTime) max(rawMagnetTime) min(rawMagnetData(1,:)) max(rawMagnetData(1,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('X [microT]','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(rawMagnetTime, rawMagnetData(2,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(rawMagnetTime) max(rawMagnetTime) min(rawMagnetData(2,:)) max(rawMagnetData(2,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Y [microT]','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(rawMagnetTime, rawMagnetData(3,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(rawMagnetTime) max(rawMagnetTime) min(rawMagnetData(3,:)) max(rawMagnetData(3,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Z [microT]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% plot raw magnetic field update rate
timeDifference = diff(rawMagnetTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(rawMagnetTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(rawMagnetTime) max(rawMagnetTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%% 11) pressure

% parsing pressure text
textFileDir = 'pressure.txt';
textPressureData = importdata(textFileDir, delimiter, headerlinesIn);
pressureTime = textPressureData.data(:,1).';
pressureTime = (pressureTime - pressureTime(1)) ./ nanoSecondToSecond;
pressureData = textPressureData.data(:,2).';

% plot pressure
figure;
plot(pressureTime, pressureData, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(pressureTime) max(pressureTime) min(pressureData) max(pressureData)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Pressure [kPa]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% plot pressure update rate
timeDifference = diff(pressureTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(pressureTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(pressureTime) max(pressureTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%% 12) gyro bias

% parsing gyro bias text
textFileDir = 'gyro_bias.txt';
textGyroBiasData = importdata(textFileDir, delimiter, headerlinesIn);
gyroBiasTime = textGyroBiasData.data(:,1).';
gyroBiasTime = (gyroBiasTime - gyroBiasTime(1)) ./ nanoSecondToSecond;
gyroBiasData = textGyroBiasData.data(:,[2 3 4]).';

% plot gyro bias X-Y-Z
figure;
subplot(3,1,1);
plot(gyroBiasTime, gyroBiasData(1,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(gyroBiasTime) max(gyroBiasTime) min(gyroBiasData(1,:)) max(gyroBiasData(1,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Gyro Bias X','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(gyroBiasTime, gyroBiasData(2,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(gyroBiasTime) max(gyroBiasTime) min(gyroBiasData(2,:)) max(gyroBiasData(2,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Gyro Bias Y','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(gyroBiasTime, gyroBiasData(3,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(gyroBiasTime) max(gyroBiasTime) min(gyroBiasData(3,:)) max(gyroBiasData(3,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Gyro Bias Z','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% plot gyro bias update rate
timeDifference = diff(gyroBiasTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(gyroBiasTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(gyroBiasTime) max(gyroBiasTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%% 13) magnet bias

% parsing magnet bias text
textFileDir = 'magnet_bias.txt';
textMagnetBiasData = importdata(textFileDir, delimiter, headerlinesIn);
magnetBiasTime = textMagnetBiasData.data(:,1).';
magnetBiasTime = (magnetBiasTime - magnetBiasTime(1)) ./ nanoSecondToSecond;
magnetBiasData = textMagnetBiasData.data(:,[2 3 4]).';

% plot magnet bias X-Y-Z
figure;
subplot(3,1,1);
plot(magnetBiasTime, magnetBiasData(1,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(magnetBiasTime) max(magnetBiasTime) min(magnetBiasData(1,:)) max(magnetBiasData(1,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Magnet Bias X','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(magnetBiasTime, magnetBiasData(2,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(magnetBiasTime) max(magnetBiasTime) min(magnetBiasData(2,:)) max(magnetBiasData(2,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Magnet Bias Y','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(magnetBiasTime, magnetBiasData(3,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(magnetBiasTime) max(magnetBiasTime) min(magnetBiasData(3,:)) max(magnetBiasData(3,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Magnet Bias Z','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% plot magnet bias update rate
timeDifference = diff(magnetBiasTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(magnetBiasTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(magnetBiasTime) max(magnetBiasTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%% 14) battery

% parsing battery text
textFileDir = 'battery.txt';
textBatteryData = importdata(textFileDir, delimiter, headerlinesIn);
batteryTime = textBatteryData.data(:,1).';
batteryTime = (batteryTime - batteryTime(1)) ./ nanoSecondToSecond;
batteryData = textBatteryData.data(:,2).';

% plot battery
figure;
plot(batteryTime, batteryData, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(batteryTime) max(batteryTime) min(batteryData) max(batteryData)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Battery [%]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure

% plot battery update rate
timeDifference = diff(batteryTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(batteryTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(batteryTime) max(batteryTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


