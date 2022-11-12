function [sLength, cutLength, interval, changeHighIdx, toHighIdx, T, onIdx] = parseClickTrain(y1, fs, tCutoff)
onIdx = find(y1 == y1(1));
toHighIdx = find(y1 == 0) + 1;
changeHighIdx = [1; intersect(onIdx,toHighIdx)];
interval = changeHighIdx(2 : end) - [1; changeHighIdx(2:end-1)];
T = 1/fs : 1/fs : length(y1)/fs;
sLength = roundn(sum(interval) / fs * 1000, -1);
tIndex = find(cumsum(interval) / fs <= tCutoff);
cutLength = roundn(sum(interval(tIndex)) / fs * 1000, -1);
end