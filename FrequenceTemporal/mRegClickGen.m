function waveOutput = mRegClickGen(ICIs, Duration, Amp, varargin)
% ICI: inter-click interval (ms), n*1 vector
% Duration: duration of click train (ms), n*1 vector
% Amp: amplitude of a single click, less or equal than 1
% fs: sample rate of the signal, default:97656

% EXAMPLE: regClick = RegClickGen(4, 2000, 1, "fs", 1000);

mIp = inputParser;
mIp.addRequired("ICIs", @(x) validateattributes(x, 'numeric', {'vector'}));
mIp.addRequired("Duration", @(x) validateattributes(x, 'numeric', {'positive'}));
mIp.addRequired("Amp", @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.addParameter("fs", 97656, @(x) validateattributes(x, 'numeric', {'numel', 1, 'positive'}));
mIp.addParameter("clickType", "pulse");
mIp.addParameter("repHead", []);
mIp.addParameter("repTail", []);
mIp.addParameter("localChange", []);
mIp.addParameter("changeICI_Tail_N", []);
mIp.addParameter("changeICI_Head_N", []);
mIp.addParameter("change_TimePoint", []);
mIp.addParameter("lastClick", false, @(x) any([islogical(x), isnumeric(x)]));
mIp.addParameter("freqpool", []);

mIp.parse(ICIs, Duration, Amp, varargin{:});

fs = mIp.Results.fs;
clickType = mIp.Results.clickType;
repHead = mIp.Results.repHead;
repTail = mIp.Results.repTail;
localChange = mIp.Results.localChange;
changeICI_Tail_N = mIp.Results.changeICI_Tail_N;
changeICI_Head_N = mIp.Results.changeICI_Head_N;
change_TimePoint = mIp.Results.change_TimePoint;
lastClick = logical(mIp.Results.lastClick);
freqpool = mIp.Results.freqpool;

if ~iscolumn(ICIs)
    ICIs = ICIs';
end
if ~iscolumn(Duration)
    Duration = Duration';
end

%% generate single click
opts.fs = fs;
opts.Amp = Amp;

clickTrainParams  = evalin("caller", "clickTrainParams");
opts.clickDur     = clickTrainParams.clickDur;% ms
try clickType = clickTrainParams.clickType; catch; clickType = "pulse"; end
if strcmpi(clickType, "toneBurst")
    opts.toneRiseFall =  clickTrainParams.toneRiseFall;% ms
    opts.freqpool = freqpool;
    click = mgenerateToneBurst(opts);

elseif  strcmpi(clickType, "pulse")
    opts.riseFallTime = 0; % ms
    click = generateClick(opts);
else
    error("illegal click type!!!");
end
%% for single click train
opts.click = click;
opts.soundLength = Duration; % ms, sound length, composed of N single trains
opts.ICIs = ICIs; % ms
[~, ~, ~, opts.regClickTrainSampN] = generateRegClickTrain(opts);

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

singleRegWave = generateRegClickTrain(opts);

if lastClick
    singleRegWave = cellfun(@(x) [x; click'], singleRegWave, "UniformOutput", false);
end

ICIs = repmat(ICIs, length(Duration), 1);
c_ICIs = num2cell(ICIs);
c_Wave = singleRegWave;
c_OnsetIdx = cellfun(@(x) [1; cumsum(x(1:end-1)) + 1], opts.regClickTrainSampN, "uni", false);
c_SampN = cellfun(@(x) diff(x), c_OnsetIdx, "uni", false);
c_LastClickOnset = cellfun(@(x) x(end)/opts.fs*1000, c_OnsetIdx, "UniformOutput", false);
c_Duration = cellfun(@(x) length(x)/opts.fs*1000, singleRegWave, "UniformOutput", false);
c_fs = num2cell(repmat(opts.fs, length(ICIs), 1));
if ~exist("freqpool", "var") | isempty(freqpool)
    waveOutput = cell2struct([c_ICIs, c_Wave, c_fs, c_OnsetIdx, c_SampN, c_LastClickOnset, c_Duration], ...
        ["ITIs", "Wave", "fs", "OnsetIdx", "SampN", "LastClickOnset", "Duration"], 2);
else
    c_freqpool = repmat({freqpool}, [numel(c_ICIs), 1]);
    waveOutput = cell2struct([c_ICIs, c_Wave, c_fs, c_OnsetIdx, c_SampN, c_LastClickOnset, c_Duration, c_freqpool], ...
        ["ITIs", "Wave", "fs", "OnsetIdx", "SampN", "LastClickOnset", "Duration", "freqpool"], 2);
end
end