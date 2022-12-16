clear; clc

loadPath = 'E:\ratNeuroPixel\monkeySounds\2022-12-14_MLA_Offset_8_16_DiffVar_500ms\offset';
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

% cellfun(@(x, y) sum(x(1 : (end - y))) / 97656 * 1000, {soundParse.interval}', num2cell([1;10;20;40;5;0;10;20;40;5]), "UniformOutput", false);
% cellfun(@(x, y) sum(x(1 : y)) / 97656 * 1000, {soundParse.interval}', num2cell([266, 267, 200, 200, 160, 160, 1000, 1000]'), "UniformOutput", false);
% sum (soundParse(2).changeHighIdx(1:249)/soundParse(1).fs*1000)
