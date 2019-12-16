function [TangoPoseResult] = parseTangoPoseTextFile(TangoPoseTextFile)

% common setting to read text files
delimiter = ' ';
headerlinesIn = 1;
nanoSecondToSecond = 1000000000;


% open Tango pose text file
textTangoPoseData = importdata(TangoPoseTextFile, delimiter, headerlinesIn);
TangoPoseTime = textTangoPoseData.data(:,1).';
TangoPoseTime = TangoPoseTime ./ nanoSecondToSecond;
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


% construct Tango VIO pose results
TangoPoseResult = struct('timestamp', cell(1,numPose), 'T_gb_Tango', cell(1,numPose), 'stateEsti_Tango', cell(1,numPose));
for k = 1:numPose
    
    % save each Tango VIO pose information
    TangoPoseResult(k).timestamp = TangoPoseTime(k);
    TangoPoseResult(k).T_gb_Tango = T_gb_Tango{k};
    TangoPoseResult(k).stateEsti_Tango = stateEsti_Tango(:,k);
end


end

