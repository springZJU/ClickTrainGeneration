function waveOutput = RegClickGen(ICIs, Duration, Amp, varargin)

mIp = inputParser;
mIp.addRequired("ICIs", @(x) validateattributes(x, 'numeric', {'vector'}));
mIp.addRequired("Duration", @(x) validateattributes(x, 'numeric', {'positive'}));
mIp.addRequired("Amp", @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.addParameter("fs", 97656, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.addParameter("repHead", []);
mIp.addParameter("repTail", []);
mIp.addParameter("lastClick", false, @(x) any([islogical(x), isnumeric(x)]));
mIp.parse(ICIs, Duration, Amp, varargin{:});

fs = mIp.Results.fs;
repHead = mIp.Results.repHead;
repTail = mIp.Results.repTail;
lastClick = logical(mIp.Results.lastClick);
%% generate single click
opts.fs = fs;
opts.Amp = Amp;
opts.clickDur = 0.2 ; % ms
opts.riseFallTime = 0; % ms
click = generateClick(opts);

%% for single click train
opts.click = click;
opts.trainLength = 100; % ms, single train
opts.soundLength = Duration; % ms, sound length, composed of N single trains
opts.ICIs = ICIs; % ms
% singleRegWave = generateRegClickTrain(opts);
[~, ~, ~, opts.regClickTrainSampN] = generateRegClickTrain(opts);
if ~isempty(find(repHead > 0, 1))
    for rIndex = 1 : length(opts.regClickTrainSampN)
        opts.regClickTrainSampN{rIndex}(1 : length(repHead)) = ceil(ICIs(rIndex)/1000*opts.fs * repHead);
    end
end
if ~isempty(find(repTail > 0, 1))
    for rIndex = 1 : length(opts.regClickTrainSampN)
        opts.regClickTrainSampN{rIndex}(1 : length(repTail)) = ceil(ICIs(rIndex)/1000*opts.fs * repTail);
    end
end
singleRegWave = generateRegClickTrain(opts);

if lastClick
    singleRegWave = cellfun(@(x) [x; click'], singleRegWave, "UniformOutput", false);
end


c_ICIs = num2cell(ICIs);
c_Wave = singleRegWave;
c_OnsetIdx = cellfun(@(x) [1; find(diff(x) > 0) + 1], singleRegWave, "uni", false);
c_SampN = cellfun(@(x) diff(x), c_OnsetIdx, "uni", false);
c_LastClickOnset = cellfun(@(x) x(end)/opts.fs*1000, c_OnsetIdx, "UniformOutput", false);
c_Duration = cellfun(@(x) length(x)/opts.fs*1000, singleRegWave, "UniformOutput", false);
c_fs = num2cell(repmat(opts.fs, length(ICIs), 1));
waveOutput = cell2struct([c_ICIs, c_Wave, c_fs, c_OnsetIdx, c_SampN, c_LastClickOnset, c_Duration], ["ICIs", "Wave", "fs", "OnsetIdx", "SampN", "LastClickOnset", "Duration"], 2);
end