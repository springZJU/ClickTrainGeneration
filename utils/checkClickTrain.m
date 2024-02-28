clear; clc


loadPath = 'E:\sounds\RatLinearArray\2023-09-14_RNP_Offset_Var_4ms_Last32\';

tCutoff = 18;
files = dir(loadPath);
files(matches({files.name}, ".") | matches({files.name}, "..") | ~contains({files.name}, ".wav")) = [];

[y1, fs] = cellfun(@(x) audioread(fullfile(loadPath, x)), {files.name}', "UniformOutput", false);
[yLength, sLength, cutLength, interval, changeHighIdx, changeHighTime, toHighIdx, T, onIdx] = cellfun(@(x, y) parseClickTrain(x, y, tCutoff), y1, fs, "UniformOutput", false);

Fields = {'name', 'sLength', 'cutLength', 'interval', 'y1', 'fs', 'changeHighIdx', 'changeHighTime', 'toHighIdx', 'T', 'onIdx'}';
Values = [{files.name}', sLength, cutLength, interval, y1, fs, changeHighIdx, changeHighTime, toHighIdx, T, onIdx, num2cell(ones(length(T), 1) * tCutoff)];

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
soundSel = [4];
for sIndex = 1 : length(soundSel)
    subplot(2, 2, sIndex);
    temp = soundParse(soundSel(sIndex)).interval;
    Fig(sIndex) = histogram(temp, "BinEdges", 0:10:800);
    title(['variance of ICIs is: ', num2str(std(temp)), '(u/', num2str(roundn(391/std(temp), -2)), ')']);
end

%% plot raw wave
Fig = figure;
maximizeFig(Fig);
sIndex = 4;
plot((1:length(soundParse(sIndex).y1))/soundParse(sIndex).fs, soundParse(sIndex).y1); hold on
xlim([1.9, 2.1]);


%% localChange Time Course
temp = cumsum(soundParse.interval);
changeTime = temp(soundParse.interval==397)*1000/soundParse.fs;