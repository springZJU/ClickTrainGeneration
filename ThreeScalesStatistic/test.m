% deleteItem("D:\LAB\MonkeyNeuroPixels\2024-02-15_MNP_TB-ThreeScales_Skew");
% run("generateThreeScaleStatistic.m");
%% Skew Protocol
SD = ["control", "p=1.1", "p=2", "p=4", "p=6"];
load("..\..\MonkeyNeuroPixels\2024-02-16_MNP_TB-ThreeScales_Skew\sounds.mat")
colNum = length(sounds.Wave)/2;
figure

% train 1
subplot(1, colNum+1, 1)
temp = sounds.Wave(vIndex).StdWave.SampN / 97656 * 1000;
histogram(temp);
title({char(SD(1)); ...
            ['skewness = ', num2str(roundn(skewness(temp), -2))]; ...
             ['mean = ', num2str(roundn(mean(temp), -2))]; ...
             ['std = ', num2str(roundn(std(temp), -2))]});

% trains 2
for vIndex = 1 : colNum
subplot(1, colNum+1, vIndex+1)
temp = sounds.Wave(vIndex).DevWave.SampN / 97656 * 1000;
histogram(temp);
title({char(SD(vIndex+1)); ...
            ['skewness = ', num2str(roundn(skewness(temp), -2))]; ...
             ['mean = ', num2str(roundn(mean(temp), -2))]; ...
             ['std = ', num2str(roundn(std(temp), -2))]});
end
scaleAxes("x", "on");  

%% SD Protocol
SD = ["d=4", "d=8", "d=16", "d=32", "d=64"];
load("..\..\MonkeyNeuroPixels\2024-02-21_MNP_TB-ThreeScales_Variance\sounds.mat")
colNum = length(sounds);

figure
% trains 2
for vIndex = 1 : colNum
subplot(1, colNum, vIndex)
temp = sounds(vIndex).Wave(1).DevWave.SampN / 97656 * 1000;
histogram(temp);
title({char(SD(vIndex)); ...
             ['mean = ', num2str(roundn(mean(temp), -2))]; ...
             ['std = ', num2str(roundn(std(temp), -2))]});
end
scaleAxes("x", "on");  

%% Mean Protocol
Mean = ["u=4", "u=4.01", "u=4.02", "u=4.03", "u=4.06"];
load("..\..\MonkeyNeuroPixels\2024-02-16_MNP_TB-ThreeScales_Mean\sounds.mat")
colNum = length(sounds);

figure
% trains 2
for vIndex = 1 : colNum
subplot(1, colNum, vIndex)
temp = sounds(vIndex).Wave(1).DevWave.SampN / 97656 * 1000;
histogram(temp);
title(char(Mean(vIndex))); ...
end
scaleAxes("x", "on");  