function [reward] = computeRewardMetric(queryRSSI, databaseRSSI)

% model parameters for Huber and Tukey functions
HuberParameter = 10;
TukeyParameter = 160;


% compute the reward between RSSI vectors
numUniqueAPs = size(queryRSSI,1);
rewardSum = 0;
rewardCount = 0;
for m = 1:numUniqueAPs
    
    % current element from RSSI vectors
    p = queryRSSI(m);
    q = databaseRSSI(m);
    
    % calculate the reward
    if ((p == -200) && (q == -200))
        continue;
    else
        rewardTemp = HuberFunction(abs(p - q), HuberParameter) * TukeyFunction(abs((p + q) / 2), TukeyParameter);
        rewardSum = rewardSum + rewardTemp;
        rewardCount = rewardCount + 1;
    end
end


% calculate the average reward metric
reward = 0;
if ((rewardCount ~= 0) && (rewardCount > 15))
    reward = rewardSum / rewardCount;
end


end

