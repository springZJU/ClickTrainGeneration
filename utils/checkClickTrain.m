clear; clc

loadPath = 'E:\ratNeuroPixel\MonkeyLinearArray\2023-02-07_MLA_Offset_Var_4_16_v1';
tCutoff = 18;
files = dir(loadPath);
files(matches({files.name}, ".") | matches({files.name}, "..") | ~contains({files.name}, ".wav")) = [];

[y1, fs] = cellfun(@(x) audioread(fullfile(loadPath, x)), {files.name}', "UniformOutput", false);
[yLength, sLength, cutLength, interval, changeHighIdx, toHighIdx, T, onIdx] = cellfun(@(x, y) parseClickTrain(x, y, tCutoff), y1, fs, "UniformOutput", false);

Fields = {'name', 'sLength', 'cutLength', 'interval', 'y1', 'fs', 'changeHighIdx', 'toHighIdx', 'T', 'onIdx'}';
Values = [{files.name}', sLength, cutLength, interval, y1, fs, changeHighIdx, toHighIdx, T, onIdx, num2cell(ones(length(T), 1) * tCutoff)];

soundParse = easyStruct(Fields, Values);

optPath = [fileparts(loadPath), '\opts.mat'];
if exist(optPath, "file")
    load(optPath);
    singleDuration = opts.soundRealDuration;
end
clearvars -except singleDuration soundParse

keyboard
%% histogram of ICI
Fig = figure;
maximizeFig(Fig);
soundSel = [15, 16, 13, 14];
for sIndex = 1 : length(soundSel)
    subplot(2, 2, sIndex);
    temp = soundParse(soundSel(sIndex)).interval;
    histogram(temp, "BinEdges", 0:10:800);
    title(['variance of ICIs is: ', num2str(std(temp)), '(u/', num2str(roundn(391/std(temp), -2)), ')']);
end