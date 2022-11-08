function [sLength, interval, changeHighIdx, toHighIdx, T, onIdx] = parseClickTrain(y1, fs)
onIdx = find(y1 == y1(1));
toHighIdx = find(y1 == 0) + 1;
changeHighIdx = [1; intersect(onIdx,toHighIdx)];
interval = changeHighIdx(2 : end) - [1; changeHighIdx(2:end-1)];
T = 1/fs : 1/fs : length(y1)/fs;
sLength = length(y1) / fs;

end