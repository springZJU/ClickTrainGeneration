function res = merge_FreqTemp_Sequence(varargin)
mIp = inputParser;

mIp.addParameter("Seq_Tag", [], @(x) isstring(x));
mIp.addParameter("Std_Wave", [], @(x) isstruct(x));
mIp.addParameter("Dev_Wave", [], @(x) isstruct(x));
mIp.addParameter("clickType", [], @(x) isstring(x));
mIp.addParameter("ISI", 0, @(x) validateattributes(x, {'numeric'}, {'positive'}));
mIp.parse(varargin{:});

Seq_Tag = mIp.Results.Seq_Tag;
Std_Wave = mIp.Results.Std_Wave;
Dev_Wave = mIp.Results.Dev_Wave;
clickType = mIp.Results.clickType;
ISI = mIp.Results.ISI;

if isempty(Seq_Tag)
    error("Sequence Tag is missing!!!");
end
if isempty(Std_Wave)
    error("Std Wave is missing!!!");
end
if isempty(Dev_Wave)
    error("Dev Wave is missing!!!");
end

res.fs = Dev_Wave.fs;
res.Tag = Seq_Tag;
if ISI == 0
    res.Wave = cell2mat([{Std_Wave.Wave}'; Dev_Wave.Wave]);
    res.StdDev_OnsetSeq = 1/res.fs * 1000 +  [0; cumsum(vertcat(Std_Wave.Duration))];
    res.StdDev_OnsetIndex = cumsum([1; cellfun(@(x) numel(x), {Std_Wave.Wave}')]);
else
    ISIWave = {zeros(ceil(ISI / 1000 * res.fs) - numel(Std_Wave(1).Wave), 1)};
    res.Wave = cell2mat([reshape(vertcat({Std_Wave.Wave}, repmat(ISIWave, 1, numel(Std_Wave))), [], 1); ...
        Dev_Wave.Wave]);
    res.StdDev_OnsetSeq = (1/res.fs +  [0; cumsum(cellfun(@(x) numel(cell2mat(vertcat(x, ISIWave))), {Std_Wave.Wave})') / res.fs]) * 1000;
    res.StdDev_OnsetIndex = cumsum([1; cellfun(@(x) numel(cell2mat(vertcat(x, ISIWave))), {Std_Wave.Wave})']);
end
res.StdTrainSampN = cellfun(@(stdSeq)numel(stdSeq), {Std_Wave.Wave});
res.DevTrainSampN = numel(Dev_Wave.Wave);
res.ITISeq = [vertcat(Std_Wave.ITIs); Dev_Wave.ITIs];
res.FreqSeq = [{Std_Wave.freqpool}'; {Dev_Wave.freqpool}];
res.Interval = diff(res.StdDev_OnsetIndex);
res.SeqOffset = numel(res.Wave) / res.fs * 1000;
if ~contains(Seq_Tag, "ManyStd")
    if isequal(Std_Wave(1).freqpool, Dev_Wave.freqpool) & ~isequal(Std_Wave(1).ITIs, Dev_Wave.ITIs)
        res.Name = strcat(Seq_Tag, "_StdITI", strrep(num2str(Std_Wave(1).ITIs), ".", "o"), "_DevITI", strrep(num2str(Dev_Wave.ITIs), ".", "o"),...
           "_Freq", strjoin(string(fix(Std_Wave(1).freqpool)), "-"), "_ISI-", num2str(ISI), "ms_StdDur-", num2str(round(Std_Wave(1).Duration))...
            , "ms_StdNum-", num2str(length(Std_Wave)), ".wav");
    elseif ~isequal(Std_Wave(1).freqpool, Dev_Wave.freqpool) & isequal(Std_Wave(1).ITIs, Dev_Wave.ITIs)
        fRatio = roundn(unique(Dev_Wave.freqpool/Std_Wave(1).freqpool), -2);
        res.Name = strcat(Seq_Tag, "_StdITI", strrep(num2str(Std_Wave(1).ITIs), ".", "o"), "_DevITI", strrep(num2str(Dev_Wave.ITIs), ".", "o"),...
           "_Freq", strjoin(string(fix(Std_Wave(1).freqpool)), "-"), "_fRatio-", strrep(string(fRatio), ".", "o"),...
           "_ISI-", num2str(ISI), "ms_StdDur-", num2str(round(Std_Wave(1).Duration)),...
           "ms_StdNum-", num2str(length(Std_Wave)), ".wav");   
    end
else
    res.Name = '';
end

