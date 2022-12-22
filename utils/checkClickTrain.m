clear; clc

loadPath = 'E:\F2RatLinearArray\RatLinearArray\2022-12-20_RLA_Variance';
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
