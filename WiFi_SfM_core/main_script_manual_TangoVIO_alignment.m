clc;
close all;
clear variables; %clear classes;
rand('state',0); % rand('state',sum(100*clock));
dbstop if error;


%% perform manual alignment for global inertial frame

% parse pose.txt file (from ASUS Tango)
[TangoPoseReference] = parseTangoPoseTextFile('pose_reference.txt');
[TangoPoseTest] = parseTangoPoseTextFile('pose_test.txt');
poseReference = [TangoPoseReference(:).stateEsti_Tango];
poseTest = [TangoPoseTest(:).stateEsti_Tango];


% find yaw / translation x-y-z
yaw = 183.5;
tx = -0.0;
ty = 1.5;
tz = 0;


% manual coordinate alignment (global inertial frame)
R = angle2rotmtx([0;0;(deg2rad(yaw))]);
t = [tx; ty; tz];


% transform Tango VIO trajectory
poseTestTransformed = R * poseTest(1:3,:);
poseTestTransformed = poseTestTransformed + t;


% plot Tango VIO motion estimation results
figure;
plot3(poseReference(1,:),poseReference(2,:),poseReference(3,:),'k','LineWidth',2); hold on; grid on;
plot3(poseTestTransformed(1,:),poseTestTransformed(2,:),poseTestTransformed(3,:),'r','LineWidth',2);
plot_inertial_frame(0.5); axis equal; view(0, 90);
xlabel('x [m]','fontsize',10); ylabel('y [m]','fontsize',10); zlabel('z [m]','fontsize',10); hold off;


%%

% load dataset lists (Android Sensors-Data-Logger App from ASUS Tango)
datasetPath = 'G:/Smartphone_Dataset/4_WiFi_SfM/Asus_Tango';
datasetList = dir(datasetPath);
datasetList(1:2) = [];


% parse all pose.txt files
numDatasetList = size(datasetList,1);
datasetTangoPoseResult = cell(1,numDatasetList);
for k = 1:numDatasetList
    
    % parse pose.txt file
    currentPoseTextFile = [datasetPath '/' datasetList(k).name '/pose.txt'];
    TangoPoseResult = parseTangoPoseTextFile(currentPoseTextFile);
    
    
    % transform to global inertial frame
    if (k ~=1)
        
        %
        expCase = k;
        setupParams_Asus_Tango_Dataset;
        
        
        
        
    end
    
    
    % save Tango pose VIO result
    datasetTangoPoseResult{k} = TangoPoseResult;
end
























