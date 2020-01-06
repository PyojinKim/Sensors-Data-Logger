function [magnetResult] = parseMagnetTextFile(magnetTextFile)

% common setting to read text files
delimiter = ' ';
headerlinesIn = 1;
nanoSecondToSecond = 1000000000;


% open calibrated magnetic field text file
textMagnetData = importdata(magnetTextFile, delimiter, headerlinesIn);
magnetTime = textMagnetData.data(:,1).';
magnetTime = magnetTime ./ nanoSecondToSecond;
magnetData = textMagnetData.data(:,[2 3 4]).';


% construct calibrated magnet results
numMagnet = size(magnetData,2);
magnetResult = struct('timestamp', cell(1,numMagnet), 'magnet', cell(1,numMagnet));
for k = 1:numMagnet
    
    % save each calibrated magnetic field information
    magnetResult(k).timestamp = magnetTime(k);
    magnetResult(k).magnet = magnetData(:,k);
end


end

