deleteItem("D:\LAB\MonkeyNeuroPixels\2024-02-15_MNP_TB-ThreeScales_Skew");
run("generateThreeScaleStatistic.m");
%%
load("D:\LAB\MonkeyNeuroPixels\2024-02-16_MNP_TB-ThreeScales_Skew_8ms\sounds.mat")

figure
colNum = length(sounds.Wave)/2;
for vIndex = 1 : colNum
subplot(2, colNum, vIndex)
temp = sounds.Wave(vIndex).StdWave.SampN / 97656 * 1000;
histogram(temp);
subplot(2, colNum, vIndex+colNum)
temp = sounds.Wave(vIndex).DevWave.SampN / 97656 * 1000;
histogram(temp);
title({['skewness = ', num2str(roundn(skewness(temp), -2))]; ...
             ['mean = ', num2str(roundn(mean(temp), -2))]; ...
             ['std = ', num2str(roundn(std(temp), -2))]});
scaleAxes("x", "on");   
end
