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
textFileDir = 'pose.txt';
textTangoPoseData = importdata(textFileDir, delimiter, headerlinesIn);
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

% plot update rate of Tango sensor pose
timeDifference = diff(TangoPoseTime);
meanUpdateRate = (1/mean(timeDifference));
figure;
plot(TangoPoseTime(2:end), timeDifference, 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(TangoPoseTime) max(TangoPoseTime) min(timeDifference) max(timeDifference)]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Time Difference [sec]','FontName','Times New Roman','FontSize',17);
title(['Mean Update Rate: ', num2str(meanUpdateRate), ' Hz'],'FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]);  % modify figure


%% plot Tango VIO results

% 1) play 3D trajectory of Tango sensor pose
figure(10);
for k = 1:numPose
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


% 2) plot Tango VIO motion estimation results
figure;
h_Tango = plot3(stateEsti_Tango(1,:),stateEsti_Tango(2,:),stateEsti_Tango(3,:),'m','LineWidth',2); hold on; grid on;
plot_inertial_frame(0.5); legend(h_Tango,{'Tango'}); axis equal; view(26, 73);
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); zlabel('z [m]','fontsize',10); hold off;

% figure options
f = FigureRotator(gca());


% 3) plot roll/pitch/yaw of Tango device orientation
figure;
subplot(3,1,1);
plot(TangoPoseTime, stateEsti_Tango(4,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(TangoPoseTime) max(TangoPoseTime) min(stateEsti_Tango(4,:)) max(stateEsti_Tango(4,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Roll [rad]','FontName','Times New Roman','FontSize',17);
subplot(3,1,2);
plot(TangoPoseTime, stateEsti_Tango(5,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(TangoPoseTime) max(TangoPoseTime) min(stateEsti_Tango(5,:)) max(stateEsti_Tango(5,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Pitch [rad]','FontName','Times New Roman','FontSize',17);
subplot(3,1,3);
plot(TangoPoseTime, stateEsti_Tango(6,:), 'm'); hold on; grid on; axis tight;
set(gcf,'color','w'); hold off;
axis([min(TangoPoseTime) max(TangoPoseTime) min(stateEsti_Tango(6,:)) max(stateEsti_Tango(6,:))]);
set(get(gcf,'CurrentAxes'),'FontName','Times New Roman','FontSize',17);
xlabel('Time [sec]','FontName','Times New Roman','FontSize',17);
ylabel('Yaw [rad]','FontName','Times New Roman','FontSize',17);
set(gcf,'Units','pixels','Position',[100 200 1800 900]); % modify figure


%% 2) Fused Location Provider (FLP)

% parsing FLP text
textFileDir = 'FLP.txt';
textFLPData = importdata(textFileDir, delimiter, headerlinesIn);
FLPTimeSec = textFLPData.data(:,1).';
FLPTimeSec = (FLPTimeSec - FLPTimeSec(1)) ./ nanoSecondToSecond;
FLPTimeHour = FLPTimeSec / (60 * 60);
FLPHorizontalPosition = textFLPData.data(:,[2 3 4]).';

% plot horizontal position (latitude / longitude) trajectory on Google map
figure;
plot(FLPHorizontalPosition(2,:), FLPHorizontalPosition(1,:), 'k', 'LineWidth', 3); hold on;
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


%% 3) RoNIN























