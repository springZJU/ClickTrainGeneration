function waveOutput = ClickTrainRep(sounds, Amp, varargin)
% ICI: inter-click interval (ms), n*1 vector
% Duration: duration of click train (ms), n*1 vector
% Amp: amplitude of a single click, less or equal than 1
% fs: sample rate of the signal, default:97656

% EXAMPLE: JitterClick = JitterClickGen(4, 2000, 1, "fs", 1000);

mIp = inputParser;
mIp.addRequired("sounds", @(x) isstruct(x));
mIp.addRequired("Amp", @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.addParameter("fs", 97656, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.addParameter("repHead", []);
mIp.addParameter("repTail", []);
mIp.addParameter("localChange", []);
mIp.addParameter("changeICI_Tail_N", []);
mIp.addParameter("changeICI_Head_N", []);
mIp.addParameter("change_TimePoint", []);
mIp.addParameter("lastClick", false, @(x) any([islogical(x), isnumeric(x)]));
mIp.parse(sounds, Amp, varargin{:});

fs = mIp.Results.fs;
repHead = mIp.Results.repHead;
repTail = mIp.Results.repTail;
localChange = mIp.Results.localChange;
changeICI_Tail_N = mIp.Results.changeICI_Tail_N;
changeICI_Head_N = mIp.Results.changeICI_Head_N;
change_TimePoint = mIp.Results.change_TimePoint;
lastClick = logical(mIp.Results.lastClick);


%% generate single click
opts.fs = fs;
opts.Amp = Amp;
opts.clickDur = 0.2 ; % ms
opts.riseFallTime = 0; % ms
click = generateClick(opts);
opts.click = click;
%% for single click train

% singleRegWave = generateRegClickTrain(opts);
opts.regClickTrainSampN = {sounds.SampN}';
opts.ICIs = sounds.ICIs;
ICIs = opts.ICIs;
% head rep
if ~isempty(find(repHead > 0, 1))
    for rIndex = 1 : length(opts.regClickTrainSampN)
        opts.regClickTrainSampN{rIndex}(1 : length(repHead)) = ceil(ICIs(rIndex)/1000*opts.fs * repHead);
    end
end

% tail rep
if ~isempty(find(repTail > 0, 1))
    for rIndex = 1 : length(opts.regClickTrainSampN)
        opts.regClickTrainSampN{rIndex}(end-length(repTail)+1 : end) = ceil(ICIs(rIndex)/1000*opts.fs * repTail);
    end
end

% changeICI_Head
if ~isempty(find(changeICI_Head_N > 0, 1))
    for rIndex = 1 : length(opts.regClickTrainSampN)
        opts.regClickTrainSampN{rIndex}([0 : length(localChange)-1] + changeICI_Head_N) = ceil(ICIs(rIndex)/1000*opts.fs * localChange);
    end
end

% changeICI_Tail
if ~isempty(find(changeICI_Tail_N > 0, 1))
    for rIndex = 1 : length(opts.regClickTrainSampN)
        opts.regClickTrainSampN{rIndex}((end-length(localChange)+1-changeICI_Tail_N : end-changeICI_Tail_N)) = ceil(ICIs(rIndex)/1000*opts.fs * localChange);
    end
end

% change_TimePoint
if isnumeric(change_TimePoint)
    for rIndex = 1 : length(opts.regClickTrainSampN)
        temp = cumsum(opts.regClickTrainSampN{rIndex})/fs;
        idx = interp1(temp, 1:length(temp), change_TimePoint, "nearest");
        idx(isnan(idx)) = [];
        for cIndex = 1 : length(idx)
            opts.regClickTrainSampN{rIndex}([0 : length(localChange)-1] + idx(cIndex)) = ceil(ICIs(rIndex)/1000*opts.fs * localChange);
        end
    end
end

singleWave = generateJitterClickTrain(opts);
if lastClick
    singleWave = cellfun(@(x) [x; click'], singleWave, "UniformOutput", false);
end


c_ICIs = {sounds.ICIs}';
c_Wave = singleWave;
c_OnsetIdx = cellfun(@(x) [1; find(diff(x) > 0) + 1], singleWave, "uni", false);
c_SampN = cellfun(@(x) diff(x), c_OnsetIdx, "uni", false);
c_LastClickOnset = cellfun(@(x) x(end)/opts.fs*1000, c_OnsetIdx, "UniformOutput", false);
c_Duration = cellfun(@(x) length(x)/opts.fs*1000, singleWave, "UniformOutput", false);
c_fs = num2cell(repmat(opts.fs, length(ICIs), 1));
waveOutput = cell2struct([c_ICIs, c_Wave, c_fs, c_OnsetIdx, c_SampN, c_LastClickOnset, c_Duration], ["ICIs", "Wave", "fs", "OnsetIdx", "SampN", "LastClickOnset", "Duration"], 2);
end