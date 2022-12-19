function [waveOutput,  irregICISampNBase] = IrregClickGen(ICIs, Duration, Amp, varargin)

% example: IrregWave = IrregClickGen(6, 300, 4, 2, "repHead", [0.9, 1.1], "repTail", [1.1, 0.9]);
mIp = inputParser;
mIp.addRequired("ICIs", @(x) validateattributes(x, 'numeric', {'vector'}));
mIp.addRequired("Duration", @(x) validateattributes(x, 'numeric', {'positive'}));
mIp.addRequired("Amp", @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.addParameter("baseICI", 4, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.addParameter("variance", 2, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.addParameter("fs", 97656, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.addParameter("irregICISampNBase", [], @(x) validateattributes(x, 'numeric', {'vector', 'positive'}));
mIp.addParameter("repHead", []);
mIp.addParameter("repTail", []);
mIp.addParameter("lastClick", false, @(x) any([islogical(x), isnumeric(x)]));
mIp.parse(ICIs, Duration, Amp, varargin{:});

fs = mIp.Results.fs;
baseICI = mIp.Results.baseICI;
variance = mIp.Results.variance;
repHead = mIp.Results.repHead;
repTail = mIp.Results.repTail;
irregICISampNBase = mIp.Results.irregICISampNBase;
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

opts.baseICI =  baseICI; % ms
opts.sigmaPara = variance; % sigma = μ / sigmaPara
if isempty(irregICISampNBase)
    irregICISampNBase = cell2mat(irregICISampN(opts));
    opts.irregICISampNBase = irregICISampNBase;
else
    opts.irregICISampNBase = irregICISampNBase;
end
if ~isempty(find(repHead > 0, 1))
    opts.irregICISampNBase(1 : length(repHead)) = ceil(baseICI/1000*opts.fs * repHead);
end
if ~isempty(find(repTail > 0, 1))
    opts.irregICISampNBase(end-length(repTail)+1 : end) = ceil(baseICI/1000*opts.fs * repTail);
end

singleIrregWave = generateIrregClickTrain(opts);
if lastClick
    singleIrregWave = cellfun(@(x) [x; click'], singleIrregWave, "UniformOutput", false);
end

c_ICIs = num2cell(ICIs);
c_Wave = singleIrregWave;
c_OnsetIdx = cellfun(@(x) [1; find(diff(x) > 0) + 1], singleIrregWave, "uni", false);
c_SampN = cellfun(@(x) diff(x), c_OnsetIdx, "uni", false);
c_LastClickOnset = cellfun(@(x) x(end)/opts.fs*1000, c_OnsetIdx, "UniformOutput", false);
c_Duration = cellfun(@(x) length(x)/opts.fs*1000, singleIrregWave, "UniformOutput", false);
c_fs = num2cell(repmat(opts.fs, length(ICIs), 1));
waveOutput = cell2struct([c_ICIs, c_Wave, c_fs, c_OnsetIdx, c_SampN, c_LastClickOnset, c_Duration], ["ICIs", "Wave", "fs", "OnsetIdx", "SampN", "LastClickOnset", "Duration"], 2);
end