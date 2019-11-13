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
TangoPoseTime = textTangoPoseData.data(:,1).';
TangoPoseTime = (TangoPoseTime - TangoPoseTime(1)) ./ nanoSecondToSecond;
TangoPoseRotation = textTangoPoseData.data(:,[5 2 3 4]).';
TangoPoseTranslation = textTangoPoseData.data(:,[6 7 8]).';

% Tango sensor pose with various 6-DoF sensor pose representations
numPose = size(TangoPoseRotation,2);
R_gb_Tango = zeros(3,3,numPose);
T_gb_Tango = cell(1,numPose);
stateEsti_Tango = zeros(6,numPose);
for k = 1:numPose
    
    % rigid body transformation matrix (4x4) (rotation matrix SO(3) from quaternion)
    R_gb_Tango(:,:,k) = q2r(TangoPoseRotation(:,k));
    T_gb_Tango{k} = [R_gb_Tango(:,:,k), TangoPoseTranslation(:,k); [0, 0, 0, 1]];
    
    % state vector and rotation matrix
    stateEsti_Tango(1:3,k) = T_gb_Tango{k}(1:3,4);
    [yaw, pitch, roll] = dcm2angle(R_gb_Tango(:,:,k));
    stateEsti_Tango(4:6,k) = [roll; pitch; yaw];
end

% rotate Tango trajectory (X-Y plane) only for pretty visualization
R = angle2rotmtx([0;0;(deg2rad(45))]);
stateEsti_Tango(1:3,:) = R * stateEsti_Tango(1:3,:);

% plot Tango VIO motion estimation results
figure;
h_Tango = plot3(stateEsti_Tango(1,:),stateEsti_Tango(2,:),stateEsti_Tango(3,:),'k','LineWidth',2); hold on; grid on;
plot_inertial_frame(0.5); legend(h_Tango,{'Tango'}); axis equal; view(26, 73);
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); zlabel('z [m]','fontsize',10); hold off;

view(-90, 90);
TangoPoseTime(end)/60


%% 2) RoNIN by IMUs

% parsing RoNIN text
textRoninData = importdata('ronin.txt', delimiter, headerlinesIn);
deviceRoninTime = textRoninData.data(:,1).';
deviceRoninTrajectory = textRoninData.data(:,[2:3]).';
deviceRoninTrajectory(1,:) = (deviceRoninTrajectory(1,:) - deviceRoninTrajectory(1,1));
deviceRoninTrajectory(2,:) = (deviceRoninTrajectory(2,:) - deviceRoninTrajectory(2,1));

% rotate RoNIN trajectory (X-Y plane) only for pretty visualization
R = angle2rotmtx([0;0;(deg2rad(0))]);
R = R(1:2,1:2);
deviceRoninTrajectory = R * deviceRoninTrajectory;

% plot RoNIN 2D trajectory
figure;
h_ronin = plot(deviceRoninTrajectory(1,:), deviceRoninTrajectory(2,:),'m','LineWidth',2); hold on; grid on; axis equal;
plot_inertial_frame(0.5); legend([h_ronin],{'RoNIN'}); axis tight; hold off;
xlabel('x [m]','FontName','Times New Roman','FontSize',17);
ylabel('y [m]','FontName','Times New Roman','FontSize',17);

view(180,90);


%% 3) Fused Location Provider by Google (FLP)

% parsing FLP text
textFLPData = importdata('FLP.txt', delimiter, headerlinesIn);
FLPTimeSec = textFLPData.data(:,1).';
FLPTimeSec = (FLPTimeSec - FLPTimeSec(1)) ./ nanoSecondToSecond;
FLPTimeHour = FLPTimeSec / (60 * 60);
FLPHorizontalPosition = textFLPData.data(:,[2 3 4]).';

% plot horizontal position (latitude / longitude) trajectory on Google map
figure;
plot(FLPHorizontalPosition(2,:), FLPHorizontalPosition(1,:), 'k*-', 'LineWidth', 1); hold on;
plot_google_map('maptype', 'roadmap', 'APIKey', 'AIzaSyB_uD1rGjX6MJkoQgSDyjHkbdu-b-_5Bjg');
legend('Fused Location Provider (FLP)'); hold off;
xlabel('Longitude [deg]','FontName','Times New Roman','FontSize',17);
ylabel('Latitude [deg]','FontName','Times New Roman','FontSize',17);

% plot FLP update rate
timeDifference = diff(FLPTimeSec);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(FLPTimeSec(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(FLPTimeSec) max(FLPTimeSec) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 50 1800 900]);  % modify figure









%% unbiased vs raw rotation rate comparison

% compute gyro bias difference
gyroBiasData = unbiasedGyroData - rawGyroData;

% plot gyro bias difference X-Y-Z
figure;
subplot(3,1,1);
plot(unbiasedGyroTime, gyroBiasData(1,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(unbiasedGyroTime) max(unbiasedGyroTime) min(gyroBiasData(1,:)) max(gyroBiasData(1,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(unbiasedGyroTime, gyroBiasData(2,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(unbiasedGyroTime) max(unbiasedGyroTime) min(gyroBiasData(2,:)) max(gyroBiasData(2,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(unbiasedGyroTime, gyroBiasData(3,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(unbiasedGyroTime) max(unbiasedGyroTime) min(gyroBiasData(3,:)) max(gyroBiasData(3,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


% compute gyro bias norm
for k = 1:size(gyroBiasData,2)
    gyroBiasDataNorm(k) = norm(gyroBiasData(:,k));
end

% plot gyro bias norm
figure;
plot(unbiasedGyroTime, gyroBiasDataNorm, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(unbiasedGyroTime) max(unbiasedGyroTime) min(gyroBiasDataNorm) max(gyroBiasDataNorm)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Gyro Bias','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%%




