%% make .avi file from png files

movie = VideoWriter('myAVI.avi');
movie.FrameRate = 2;  % set fps
open(movie);

for imgIdx = 1:numData
    
    % read PNG image file
    filename = [SaveImDir sprintf('/%06d.png',imgIdx)];
    im = imread(filename);
    
    % write video
    writeVideo(movie, im);
    
    imgIdx
end

close(movie);


%% make .avi file from png files

datasetPath = 'G:/ICSLRGBDdataset/rgbd_dataset_301_13_square1/rgb/';
imgName = dir(datasetPath);
imgName(1:2) = [];
M = size(imgName,1);

movie = VideoWriter('myAVI.avi');
movie.FrameRate = 20;  % set fps
open(movie);

for imgIdx = 1:M
    
    % read PNG image file
    filename = [datasetPath imgName(imgIdx).name];
    im = imread(filename);
    
    % write video
    writeVideo(movie, im);
    
    imgIdx
end

close(movie);


