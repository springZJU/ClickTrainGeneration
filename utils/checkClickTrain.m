clear; clc

loadPath = 'E:\ratNeuroPixel\monkeySounds\2022-11-17_MLA_TITS_40_24_26o4\interval 0';
tCutoff = 18;
files = dir(loadPath);
files(matches({files.name}, ".") | matches({files.name}, "..") | ~contains({files.name}, ".wav")) = [];

[y1, fs] = cellfun(@(x) audioread(fullfile(loadPath, x)), {files.name}', "UniformOutput", false);
[yLength, sLength, cutLength, interval, changeHighIdx, toHighIdx, T, onIdx] = cellfun(@(x, y) parseClickTrain(x, y, tCutoff), y1, fs, "UniformOutput", false);


% for regular
changeIdx = cellfun(@(x) find(x - x(1) ~= 0, 1, "first") - 1, interval, "UniformOutput", false);
changeIdx(isemptycell(changeIdx)) = {1};
changeTime = cellfun(@(x, y) sum(x(1 : y) / fs{1}), interval, changeIdx, "UniformOutput", false);
changeIdx = cellfun(@(x) find(x - x(1) ~= 0, 1, "first"), interval, "UniformOutput", false);

% generate soundParse
Fields = {'name', 'changeTime', 'yLength', 'sLength', 'cutLength', 'interval', 'changeIdx', 'y1', 'fs', 'changeHighIdx', 'toHighIdx', 'T', 'onIdx'}';
Values = [{files.name}', changeTime, yLength, sLength, cutLength, interval, changeIdx, y1, fs, changeHighIdx, toHighIdx, T, onIdx, num2cell(ones(length(T), 1) * tCutoff)];
soundParse = easyStruct(Fields, Values);

singleDuration = [];
temp = what(fileparts(loadPath));
optsNames = string(temp.mat);
for mIndex = 1 : length(optsNames)
    load(fullfile(fileparts(loadPath), optsNames(mIndex)));
    try
        singleDuration.(erase(optsNames(mIndex), ".mat")) = opts.soundRealDuration;
    catch 
        singleDuration.(erase(optsNames(mIndex), ".mat")) = toneOpts;
    end
end

clearvars -except singleDuration soundParse


% % for Species duration
% soundSel = [4:16:68, 8:16:72, 12:16:76, 16:16:80, 2:16:66, 6:16:70, 10:16:74, 14:16:78];
% temp = soundParse(soundSel);

% % for Species variance
% soundSel = [6:10, 16:20, 26:30, 36:40, 1:5, 11:15, 21:25, 31:35];
% temp = soundParse(soundSel);

% % for Species Control
% temp = [36, 35, 33, 31, 34, 32, 36, 35, 36, 35];
% soundSel = [temp,  temp + 36, temp - 18, temp + 18];
% temp = soundParse(soundSel);

% for MLA_CLT_Var
% u/100: 1:498
% u/200: 1:499
% u/400: 1:499
% u/50: 1:498
sum(soundParse(4).interval(1:499)) / soundParse(1).fs


% cellfun(@(x, y) sum(x(1 : (end - y))) / 97656 * 1000, {soundParse.interval}', num2cell([1;10;20;40;5;0;10;20;40;5]), "UniformOutput", false);
% cellfun(@(x, y) sum(x(1 : y)) / 97656 * 1000, {soundParse.interval}', num2cell([266, 267, 200, 200, 160, 160, 1000, 1000]'), "UniformOutput", false);

