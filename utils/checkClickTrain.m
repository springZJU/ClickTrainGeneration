clear; clc

loadPath = 'E:\ratNeuroPixel\monkeySounds\2022-11-11_Offset_15_Rep\decoding';
tCutoff = 11;
files = dir(loadPath);
files(matches({files.name}, ".") | matches({files.name}, "..") | ~contains({files.name}, ".wav")) = [];

[y1, fs] = cellfun(@(x) audioread(fullfile(loadPath, x)), {files.name}', "UniformOutput", false);
[sLength, cutLength, interval, changeHighIdx, toHighIdx, T, onIdx] = cellfun(@(x, y) parseClickTrain(x, y, tCutoff), y1, fs, "UniformOutput", false);

Fields = {'name', 'sLength', 'cutLength', 'interval', 'y1', 'fs', 'changeHighIdx', 'toHighIdx', 'T', 'onIdx'}';
Values = [{files.name}', sLength, cutLength, interval, y1, fs, changeHighIdx, toHighIdx, T, onIdx, num2cell(ones(length(T), 1) * tCutoff)];

soundParse = easyStruct(Fields, Values);

optPath = [fileparts(loadPath), '\opts.mat'];
if exist(optPath, "file")
    load(optPath);
    singleDuration = opts.soundRealDuration;
end
clearvars -except singleDuration soundParse

cellfun(@(x, y) sum(x(1 : (end - y))) / 97656 * 1000, {soundParse.interval}', num2cell([1;10;20;40;5;0;10;20;40;5]), "UniformOutput", false);
% %%
% S1Duration = 5000/1000;
% TT = (1/fs : 1/fs : length(y1)/fs) - S1Duration;
% % figure;
% % plot(y1); hold on
% % plot(repmat(ceil(length(y1) /2), 1, 2), [-1, 1], "r-");
% % xlim(fix([length(y1) /2 - 100 ,length(y1)/2 + 200]));
% % spectrum f
% 
% % irreg
% waveT = y1(TT > -4 & TT < 0);
% L = length(waveT);
% Y1 = fft(waveT);
% P2 = abs(Y1/L);
% P1Irreg = P2(1:L/2+1);
% P1Irreg(2:end-1) = 2*P1Irreg(2:end-1);
% fIrreg = fs*(0:(L/2))/L;
% 
% 
% checkWin = [20 40] / 1000;
% tIdx = find(T > checkWin(1) & T < checkWin(2));
% 
% % figure
% % plot(T(tIdx) * 1000, y1(tIdx))
% 
% % 
% % figure
% % plot(f,P1) 
% % title('Single-Sided Amplitude Spectrum of X(t)')
% % xlim([0 500]);
% % xlabel('f (Hz)')
% % ylabel('|P1(f)|')
% 
% % 
% % 
% % length(y1) / fs
% % interval(1251:end, 2) = interval(1:1250, 1);
% % sum(interval(1:1250,1)) / fs
% % sum(interval(1251:2500,1)) / fs
% 
% 
