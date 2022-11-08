clear; clc

loadPath = 'E:\ratNeuroPixel\monkeySounds\2022-11-08_Offset2\decoding';
files = dir(loadPath);
files(matches({files.name}, ".") | matches({files.name}, "..")) = [];

[y1, fs] = cellfun(@(x) audioread(fullfile(loadPath, x)), {files.name}', "UniformOutput", false);
[sLength, interval, changeHighIdx, toHighIdx, T, onIdx] = cellfun(@(x, y) parseClickTrain(x, y), y1, fs, "UniformOutput", false);

Fields = {'name', 'sLength', 'interval', 'y1', 'fs', 'changeHighIdx', 'toHighIdx', 'T', 'onIdx'}';
Values = [{files.name}', sLength, interval, y1, fs, changeHighIdx, toHighIdx, T, onIdx];

soundParse = easyStruct(Fields, Values);

optPath = [fileparts(loadPath), '\opts.mat'];
if exist(optPath, "file")
    load(optPath);
    singleDuration = opts.soundRealDuration;
end
clearvars -except singleDuration soundParse


%%
S1Duration = 5000/1000;
TT = (1/fs : 1/fs : length(y1)/fs) - S1Duration;
% figure;
% plot(y1); hold on
% plot(repmat(ceil(length(y1) /2), 1, 2), [-1, 1], "r-");
% xlim(fix([length(y1) /2 - 100 ,length(y1)/2 + 200]));
% spectrum f

% irreg
waveT = y1(TT > -4 & TT < 0);
L = length(waveT);
Y1 = fft(waveT);
P2 = abs(Y1/L);
P1Irreg = P2(1:L/2+1);
P1Irreg(2:end-1) = 2*P1Irreg(2:end-1);
fIrreg = fs*(0:(L/2))/L;


checkWin = [20 40] / 1000;
tIdx = find(T > checkWin(1) & T < checkWin(2));

% figure
% plot(T(tIdx) * 1000, y1(tIdx))

% 
% figure
% plot(f,P1) 
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlim([0 500]);
% xlabel('f (Hz)')
% ylabel('|P1(f)|')

% 
% 
% length(y1) / fs
% interval(1251:end, 2) = interval(1:1250, 1);
% sum(interval(1:1250,1)) / fs
% sum(interval(1251:2500,1)) / fs


