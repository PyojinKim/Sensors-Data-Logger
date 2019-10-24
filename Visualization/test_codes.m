


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




