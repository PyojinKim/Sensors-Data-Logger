function [gameRVResult] = parseGameRVTextFile(gameRVTextFile)

% common setting to read text files
delimiter = ' ';
headerlinesIn = 1;
nanoSecondToSecond = 1000000000;


% open game rotation vector text file
textGameRVData = importdata(gameRVTextFile, delimiter, headerlinesIn);
gameRVTime = textGameRVData.data(:,1).';
gameRVTime = gameRVTime ./ nanoSecondToSecond;
gameRVData = textGameRVData.data(:,[5 2 3 4]).';


% convert from unit quaternion to rotation matrix
numGameRV = size(gameRVData,2);
R_gb = zeros(3,3,numGameRV);
for k = 1:numGameRV
    R_gb(:,:,k) = q2r(gameRVData(:,k));
end


% construct game rotation vector (gameRV) results
gameRVResult = struct('timestamp', cell(1,numGameRV), 'R_gb', cell(1,numGameRV));
for k = 1:numGameRV
    
    % save each game rotation vector (rotation matrix) information
    gameRVResult(k).timestamp = gameRVTime(k);
    gameRVResult(k).R_gb = R_gb(:,:,k);
end


end

