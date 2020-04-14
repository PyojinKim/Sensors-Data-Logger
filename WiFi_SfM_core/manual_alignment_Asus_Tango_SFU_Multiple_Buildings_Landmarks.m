%% manual alignment for global inertial frame

% define 2D landmark locations manually
landmark0 = [-0.4984; -0.2743];
landmark1 = [60.2155; 100.7677];
landmark2 = [-81.5979; 165.0269];
landmark3 = [-259.7510; 251.4445];
landmark4 = [-157.3795; 312.6015];
landmark5 = [147.9625; 236.8200];
landmark6 = [177.2116; 144.6412];
radius = 2.5;


switch( expCase )
    
    case 1
        % 20200316062444R_WiFi_SfM (reference inertial frame)
        startFLPLocationMeter = landmark0;
        finalFLPLocationMeter = landmark1;
        FLPAccuracyMeter = radius;
        
    case 2
        startFLPLocationMeter = landmark1;
        finalFLPLocationMeter = landmark2;
        FLPAccuracyMeter = radius;
        
    case 3
        startFLPLocationMeter = landmark2;
        finalFLPLocationMeter = landmark4;
        FLPAccuracyMeter = radius;
        
    case 4
        startFLPLocationMeter = landmark4;
        finalFLPLocationMeter = landmark2;
        FLPAccuracyMeter = radius;
        
    case 5
        startFLPLocationMeter = landmark2;
        finalFLPLocationMeter = landmark3;
        FLPAccuracyMeter = radius;
        
    case 6
        startFLPLocationMeter = landmark3;
        finalFLPLocationMeter = landmark2;
        FLPAccuracyMeter = radius;
        
    case 7
        startFLPLocationMeter = landmark2;
        finalFLPLocationMeter = landmark1;
        FLPAccuracyMeter = radius;
        
    case 8
        startFLPLocationMeter = landmark1;
        finalFLPLocationMeter = landmark0;
        FLPAccuracyMeter = radius;
        
    case 9
        startFLPLocationMeter = landmark0;
        finalFLPLocationMeter = landmark1;
        FLPAccuracyMeter = radius;
        
    case 10
        startFLPLocationMeter = landmark1;
        finalFLPLocationMeter = landmark6;
        FLPAccuracyMeter = radius;
        
    case 11
        startFLPLocationMeter = landmark6;
        finalFLPLocationMeter = [106.8707; 248.5647];
        FLPAccuracyMeter = radius;
        
    case 12
        startFLPLocationMeter = [106.8707; 248.5647];
        finalFLPLocationMeter = landmark4;
        FLPAccuracyMeter = radius;
        
    case 13
        startFLPLocationMeter = landmark4;
        finalFLPLocationMeter = landmark5;
        FLPAccuracyMeter = radius;
        
    case 14
        startFLPLocationMeter = landmark5;
        finalFLPLocationMeter = landmark6;
        FLPAccuracyMeter = radius;
        
    case 15
        startFLPLocationMeter = landmark6;
        finalFLPLocationMeter = landmark1;
        FLPAccuracyMeter = radius;
        
    case 16
        startFLPLocationMeter = landmark1;
        finalFLPLocationMeter = landmark0;
        FLPAccuracyMeter = radius;
        
    case 17
        startFLPLocationMeter = landmark1;
        finalFLPLocationMeter = landmark2;
        FLPAccuracyMeter = radius;
        
    case 18
        startFLPLocationMeter = landmark2;
        finalFLPLocationMeter = landmark4;
        FLPAccuracyMeter = radius;
        
    case 19
        startFLPLocationMeter = landmark4;
        finalFLPLocationMeter = landmark5;
        FLPAccuracyMeter = radius;
        
    case 20
        startFLPLocationMeter = landmark5;
        finalFLPLocationMeter = landmark6;
        FLPAccuracyMeter = radius;
        
    case 21
        startFLPLocationMeter = landmark6;
        finalFLPLocationMeter = landmark1;
        FLPAccuracyMeter = radius;
        
    case 22
        startFLPLocationMeter = landmark1;
        finalFLPLocationMeter = landmark2;
        FLPAccuracyMeter = radius;
        
    case 23
        startFLPLocationMeter = landmark2;
        finalFLPLocationMeter = landmark3;
        FLPAccuracyMeter = radius;
        
    case 24
        startFLPLocationMeter = landmark3;
        finalFLPLocationMeter = landmark2;
        FLPAccuracyMeter = radius;
        
    case 25
        startFLPLocationMeter = landmark2;
        finalFLPLocationMeter = landmark1;
        FLPAccuracyMeter = radius;
        
    case 26
        startFLPLocationMeter = landmark1;
        finalFLPLocationMeter = landmark0;
        FLPAccuracyMeter = radius;
        
    case 27
        startFLPLocationMeter = landmark0;
        finalFLPLocationMeter = landmark1;
        FLPAccuracyMeter = radius;
        
    case 28
        startFLPLocationMeter = landmark1;
        finalFLPLocationMeter = landmark6;
        FLPAccuracyMeter = radius;
        
    case 29
        startFLPLocationMeter = landmark6;
        finalFLPLocationMeter = landmark5;
        FLPAccuracyMeter = radius;
        
    case 30
        startFLPLocationMeter = landmark5;
        finalFLPLocationMeter = landmark4;
        FLPAccuracyMeter = radius;
        
    case 31
        startFLPLocationMeter = landmark4;
        finalFLPLocationMeter = landmark2;
        FLPAccuracyMeter = radius;
        
    case 32
        startFLPLocationMeter = landmark2;
        finalFLPLocationMeter = landmark3;
        FLPAccuracyMeter = radius;
        
    case 33
        startFLPLocationMeter = landmark3;
        finalFLPLocationMeter = landmark4;
        FLPAccuracyMeter = radius;
        
    case 34
        startFLPLocationMeter = landmark4;
        finalFLPLocationMeter = landmark3;
        FLPAccuracyMeter = radius;
        
    case 35
        startFLPLocationMeter = landmark3;
        finalFLPLocationMeter = landmark2;
        FLPAccuracyMeter = radius;
        
    case 36
        startFLPLocationMeter = landmark2;
        finalFLPLocationMeter = landmark5;
        FLPAccuracyMeter = radius;
        
    case 37
        startFLPLocationMeter = landmark5;
        finalFLPLocationMeter = landmark6;
        FLPAccuracyMeter = radius;
        
    case 38
        startFLPLocationMeter = landmark6;
        finalFLPLocationMeter = landmark1;
        FLPAccuracyMeter = radius;
        
    case 39
        startFLPLocationMeter = landmark1;
        finalFLPLocationMeter = landmark0;
        FLPAccuracyMeter = radius;
        
    case 40
        startFLPLocationMeter = landmark0;
        finalFLPLocationMeter = landmark1;
        FLPAccuracyMeter = radius;
        
    case 41
        startFLPLocationMeter = landmark1;
        finalFLPLocationMeter = landmark2;
        FLPAccuracyMeter = radius;
        
    case 42
        startFLPLocationMeter = landmark2;
        finalFLPLocationMeter = landmark4;
        FLPAccuracyMeter = radius;
        
    case 43
        startFLPLocationMeter = landmark4;
        finalFLPLocationMeter = landmark3;
        FLPAccuracyMeter = radius;
        
    case 44
        startFLPLocationMeter = landmark3;
        finalFLPLocationMeter = landmark2;
        FLPAccuracyMeter = radius;
        
    case 45
        startFLPLocationMeter = landmark2;
        finalFLPLocationMeter = landmark5;
        FLPAccuracyMeter = radius;
        
    case 46
        startFLPLocationMeter = landmark5;
        finalFLPLocationMeter = landmark6;
        FLPAccuracyMeter = radius;
        
    case 47
        startFLPLocationMeter = landmark6;
        finalFLPLocationMeter = landmark1;
        FLPAccuracyMeter = radius;
        
    case 48
        startFLPLocationMeter = landmark1;
        finalFLPLocationMeter = landmark0;
        FLPAccuracyMeter = radius;
        
    case 49
        startFLPLocationMeter = landmark5;
        finalFLPLocationMeter = landmark2;
        FLPAccuracyMeter = radius;
        
    case 50
        startFLPLocationMeter = landmark2;
        finalFLPLocationMeter = landmark3;
        FLPAccuracyMeter = radius;
        
    case 51
        startFLPLocationMeter = landmark3;
        finalFLPLocationMeter = landmark4;
        FLPAccuracyMeter = radius;
        
    case 52
        startFLPLocationMeter = landmark4;
        finalFLPLocationMeter = landmark5;
        FLPAccuracyMeter = radius;
        
    case 53
        startFLPLocationMeter = landmark5;
        finalFLPLocationMeter = landmark4;
        FLPAccuracyMeter = radius;
        
    case 54
        startFLPLocationMeter = landmark4;
        finalFLPLocationMeter = landmark3;
        FLPAccuracyMeter = radius;
        
    case 55
        startFLPLocationMeter = landmark3;
        finalFLPLocationMeter = landmark2;
        FLPAccuracyMeter = radius;
        
end
