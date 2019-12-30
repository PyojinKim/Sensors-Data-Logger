function [datasetList] = loadDatasetList(datasetPath)

datasetList = dir(datasetPath);
datasetList(1:2) = [];
datasetList(end) = [];

end
